// A factory job's whole record as a popup, the web page's job view: brief, open gate, PRs,
// workspace, ledger, files, history. Opened from a factory chip card with props {slug}.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, TextView } from "gpui-base";
import { exec, spaces, run, theme, props, closeOverlay } from "herdr";

const BASE = "http://bestija-v4:4281";
const STEP = (t) => ({ done: t.ansi2, skipped: t.dim, running: t.working, failed: t.ansi1, planned: t.dim, dropped: t.dim });

function ago(ms) {
  if (!ms) return "";
  const m = Math.round((Date.now() - ms) / 60000);
  return m < 60 ? `${m}m ago` : m < 1440 ? `${Math.round(m / 60)}h ago` : `${Math.round(m / 1440)}d ago`;
}

export default class FactoryJob extends View {
  init(_props, cx) {
    this.job = null;
    cx.spawn(async (cx) => {
      try {
        const r = await fetch(`${BASE}/job/${encodeURIComponent(props()?.slug ?? "")}`);
        this.job = r.ok ? await r.json() : { error: (await r.text()).trim() };
      } catch (e) {
        this.job = { error: String(e) };
      }
      cx.notify();
    });
  }

  text(s, color, size = 12.5) {
    return div().whitespace_normal().text_size(size).text_color(color).child(TextView.markdown(`t-${this.n++}`, s || " ").selectable(true));
  }

  tag(label, color) {
    return div().flex_none().px(6).rounded(4).bg(color + "22").text_color(color).text_size(11).child(label);
  }

  link(label, url, id, t) {
    return div().id(id).text_size(12.5).text_color(t.ansi4).cursor_pointer().hover((s) => s.text_color(t.foreground))
      .on_click(() => exec("open", [url])).child(label);
  }

  section(title, body, t) {
    return v_flex().gap(6).pt(14).child(div().text_size(12).font_semibold().text_color(t.muted).child(title)).child(body);
  }

  head(j, t) {
    const space = spaces().find((s) => s.named && s.name === j.slug);
    const p = j.progress ?? {};
    return v_flex().gap(4).pb(10).border_b_1().border_color(t.border)
      .child(h_flex().gap(8).items_center()
        .child(div().min_w(0).truncate().text_size(16).font_semibold().child(j.slug))
        .child(div().id("copy").flex_none().p(4).rounded(5).text_color(t.muted).cursor_pointer()
          .hover((s) => s.bg(t.raised).text_color(t.foreground)).on_click((_, cx) => cx.write_to_clipboard(j.slug))
          .child(svg("mods/glados-job/copy.svg").size(14)))
        .child(div().flex_1())
        .when(Boolean(space), (el) => el.child(div().id("go").px(8).py(2).rounded(5).border_1().border_color(t.border).text_size(12).text_color(t.muted)
          .hover((s) => s.bg(t.raised)).on_click(() => { run("space.select", { id: space.id }); closeOverlay(props().overlay); }).child("Go to space")))
        .child(div().id("web").px(8).py(2).rounded(5).border_1().border_color(t.border).text_size(12).text_color(t.muted)
          .hover((s) => s.bg(t.raised)).on_click(() => exec("open", [`${BASE}/#job/${encodeURIComponent(j.slug)}`])).child("Web page")))
      .child(h_flex().gap(6).items_center().flex_wrap()
        .child(this.tag(j.type, t.ansi5))
        .child(this.tag(j.status, j.status === "done" ? t.ansi2 : t.working))
        .child(this.tag(j.machine ?? "?", t.dim))
        .child(div().text_size(12).text_color(t.muted).child([p.wait ?? `${p.pct ?? 0}% · now ${p.step ?? "?"}`, j.lead ? (j.lead.closed_at ? "lead missing" : `lead ${j.lead.status}`) : "no lead"].join(" · "))))
      .when(Boolean(j.parent), (el) => el.child(this.text(`↳ ${j.parent}`, t.dim, 12)));
  }

  ledger(j, t) {
    const rows = (j.plan ?? []).filter((r) => r.status !== "dropped");
    const done = rows.filter((r) => r.status === "done" || r.status === "skipped").length;
    return this.section(`Ledger · ${done}/${rows.length} done`, v_flex().gap(6).children(rows.map((r) => h_flex().gap(10).items_start()
      .child(div().w(70).flex_none().child(this.tag(r.status, STEP(t)[r.status] ?? t.dim)))
      .child(v_flex().w(220).flex_none()
        .child(div().whitespace_normal().text_size(12.5).child(r.element === "gate" ? `gate:${r.label}` : r.element))
        .when(Boolean(r.label) && r.element !== "gate", (el) => el.child(this.text(r.label, t.dim, 11.5))))
      .child(div().w(140).flex_none().truncate().text_size(11.5).text_color(t.dim).child(r.worker ?? ""))
      .child(div().flex_1().min_w(0).child(this.text(r.note ?? "", t.muted, 12))))), t);
  }

  prs(j, t) {
    return this.section("PRs", v_flex().gap(6).children(j.prs.map((p, i) => v_flex().gap(3)
      .child(this.link(`${p.repo}#${p.number} ${p.title ?? ""}`, p.url, `pr-${i}`, t))
      .child(h_flex().gap(6).items_center().flex_wrap()
        .child(this.tag(p.state, p.state === "MERGED" ? t.ansi2 : p.state === "OPEN" ? t.ansi4 : t.dim))
        .child(div().text_size(12).text_color(t.muted).child([p.draft ? "draft" : null, `CI ${p.ci ?? "?"}${p.ci_failures ? ` ×${p.ci_failures}` : ""}`, p.review ?? "no review",
          p.latest_at && `latest ${ago(p.latest_at)}`, p.production_at && `production ${ago(p.production_at)}`].filter(Boolean).join(" · ")))
        .children((p.soak ?? []).map((s) => this.tag(`${s.stage} +${s.checkpoint}`, s.fired_at ? t.ansi2 : t.dim)))))), t);
  }

  workspace(j, t) {
    return this.section("Workspace", v_flex().gap(3)
      .children((j.servers ?? []).map((s, i) => this.link(`${s.service} · ${s.host} :${s.port}${s.up === false ? " · down" : s.up ? " · up" : ""}`, `https://${s.host}`, `srv-${i}`, t)))
      .children((j.tasks ?? []).map((k, i) => this.link(`task ${k.task_id}${k.title ? ` · ${k.title}` : ""}`, `https://app.productive.io/109-productive/tasks/${k.task_id}`, `task-${i}`, t))), t);
  }

  files(j, t) {
    return this.section(`Files · ${j.files.length}`, h_flex().gap(12).flex_wrap()
      .children(j.files.map((f, i) => this.link(f.name, `${BASE}/file?path=${encodeURIComponent(f.path)}`, `file-${i}`, t))), t);
  }

  history(j, t) {
    return this.section(`History · ${j.history.length}`, v_flex().gap(8).children([...j.history].reverse().map((h) => h_flex().gap(10).items_start()
      .child(div().w(70).flex_none().text_size(11.5).text_color(t.dim).child(ago(h.ts)))
      .child(div().w(220).flex_none().whitespace_normal().text_size(12.5).child(h.what))
      .child(div().flex_1().min_w(0).child(this.text(h.text && h.text.length > 2000 ? `${h.text.slice(0, 2000)}…` : h.text ?? "", t.muted, 12))))), t);
  }

  render() {
    const t = theme();
    const j = this.job;
    this.n = 0;
    const body = !j ? [this.text("loading…", t.dim)]
      : j.error ? [this.text(j.error, t.blocked)]
        : [
          this.head(j, t),
          ...(j.brief ? [this.section("Brief", this.text(j.brief, t.foreground), t)] : []),
          ...(j.progress?.gate ? [this.section(`Open gate: ${j.progress.gate.name}`, this.text(j.progress.gate.body, t.foreground), t)] : []),
          ...(j.prs?.length ? [this.prs(j, t)] : []),
          ...(j.servers?.length || j.tasks?.length ? [this.workspace(j, t)] : []),
          this.ledger(j, t),
          ...(j.files?.length ? [this.files(j, t)] : []),
          ...(j.history?.length ? [this.history(j, t)] : []),
        ];
    return v_flex().id("root").w_full().h(window.viewport_size().height * 0.85).bg(t.canvas).text_size(13).text_color(t.foreground)
      .child(v_flex().id("job").flex_1().min_h(0).overflow_y_scrollbar().px(18).py(14).children(body));
  }
}
