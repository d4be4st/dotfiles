// One factory feed section as a popup, opened from a factory bar chip: a card per row, folded to
// its main lines; unfolded it shows what the factory knows about it, its links and actions.
// A job's whole record opens in its own popup (glados-job).

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, spaces, run, theme, notify, props, closeOverlay, openOverlay, shared, settings } from "herdr";

const BASE = "http://bestija-v4:4281";
const TONES = (t) => ({ dim: t.dim, red: t.ansi1, green: t.ansi2, yellow: t.ansi3, blue: t.ansi4, magenta: t.ansi5, purple: t.ansi5, cyan: t.ansi6 });

function ago(ms) {
  if (!ms) return "";
  const m = Math.round((Date.now() - ms) / 60000);
  return m < 60 ? `${m}m ago` : m < 1440 ? `${Math.round(m / 60)}h ago` : `${Math.round(m / 1440)}d ago`;
}

// A proposal body: "key: value" lines (a value may run on over lines), then "## Diff".
function proposalParts(body) {
  const [head, ...diff] = String(body ?? "").split(/^## Diff\n/m);
  const kv = [];
  for (const line of head.split("\n")) {
    const m = /^(\w+): ?(.*)/.exec(line);
    if (m) kv.push([m[1], m[2]]);
    else if (kv.length && line.trim()) kv.at(-1)[1] += ` ${line.trim()}`;
  }
  return { kv: kv.filter(([k]) => k !== "status" && k !== "rung"), diff: diff.join("").trimEnd() };
}

export default class FactoryChip extends View {
  init(_props, cx) {
    this.armed = null;
    this.open = new Set();
  }

  act(action, cx) {
    if (action.confirm && this.armed !== action.post) {
      this.armed = action.post;
      return cx.notify();
    }
    this.armed = null;
    cx.spawn(async () => {
      try {
        const r = await fetch(`${BASE}${action.post}`, { method: "POST", headers: { "X-Factory": "1" } });
        notify({ title: action.label, body: (await r.text()).trim(), level: r.ok ? "success" : "error" });
      } catch (e) {
        notify({ title: action.label, body: String(e), level: "error" });
      }
    });
    cx.notify();
  }

  toggle(key, cx) {
    if (!this.open.delete(key)) this.open.add(key);
    cx.notify();
  }

  text(s, color, size = 12) {
    return div().whitespace_normal().text_size(size).text_color(color).child(s || " ");
  }

  field(label, value, t) {
    return v_flex().gap(1).child(div().text_size(11).text_color(t.dim).child(label)).child(this.text(value, t.foreground));
  }

  tag(label, color) {
    return div().flex_none().px(6).rounded(4).bg(color + "22").text_color(color).text_size(11).child(label);
  }

  button(id, label, t, onClick) {
    return div().id(id).px(8).py(2).rounded(5).border_1().border_color(t.border).text_size(12).text_color(t.muted)
      .hover((s) => s.bg(t.raised))
      .on_click((_e, cx) => { cx.stop_propagation(); onClick(cx); })
      .child(label);
  }

  mono(text, t) {
    const color = (l) => (/^(\+\+\+|---)/.test(l) ? t.foreground : l.startsWith("@@") ? t.ansi6 : l.startsWith("+") ? t.ansi2 : l.startsWith("-") ? t.ansi1 : t.muted);
    return v_flex().p(8).rounded(6).bg(t.chrome).font_family(settings().font_family ?? "JetBrains Mono").text_size(11)
      .children(text.split("\n").map((l) => div().whitespace_normal().text_color(color(l)).child(l || " ")));
  }

  fold(key, label, body, t) {
    const open = this.open.has(key);
    return v_flex().gap(4)
      .child(div().id(`fold-${key}`).text_size(11.5).text_color(t.dim).cursor_pointer().hover((s) => s.text_color(t.foreground))
        .on_click((_e, cx) => { cx.stop_propagation(); this.toggle(key, cx); })
        .child(`${open ? "▾" : "▸"} ${label}`))
      .when(open, (el) => el.child(body()));
  }

  pr(d, t) {
    const STATUS = { done: t.ansi2, failed: t.ansi1, planned: t.dim };
    return v_flex().gap(4)
      .child(this.text(`${d.repo?.split("/")[1]}#${d.number} ${d.title ?? ""}`, t.foreground))
      .child(this.text([d.draft ? "draft" : "ready", `CI ${d.ci ?? "?"}${d.ci_failures ? ` ×${d.ci_failures}` : ""}`, d.review ?? "no review", d.merge_ready ? "merge-ready" : null].filter(Boolean).join(" · "), t.muted))
      .when(Boolean(d.latest_at || d.production_at), (el) => el.child(this.text([d.latest_at && `latest ${ago(d.latest_at)}`, d.production_at && `production ${ago(d.production_at)}`].filter(Boolean).join(" · "), t.muted)))
      .when(Boolean(d.soak), (el) => el.child(h_flex().gap(4).flex_wrap()
        .children(d.soak.watch.map((w) => this.tag(w.label, STATUS[w.status] ?? t.dim)))
        .when(Boolean(d.soak.due), (el) => el.child(div().text_size(11).text_color(t.dim).child(`next in ${Math.max(0, Math.round((d.soak.due - Date.now()) / 3600000))}h`)))))
      .children(d.errors.map((e) => h_flex().gap(6).items_center()
        .child(this.tag(e.regressed ? "regressed" : e.strong ? "strong" : "weak", e.regressed || e.strong ? t.ansi1 : t.ansi3))
        .child(div().flex_1().min_w(0).truncate().text_size(11.5).text_color(t.muted).child(`${e.class ?? ""} ${e.file ?? ""}:${e.line ?? ""}`))));
  }

  kids(d, t) {
    const steps = {};
    for (const sec of shared("factory.feed")?.sections ?? []) for (const r of sec.rows) if (r.job) steps[r.job.slug] ??= r.job;
    if (!d.kids.length) return this.text("no child jobs yet", t.dim);
    return v_flex().gap(3).children(d.kids.map((k) => h_flex().gap(6).items_center()
      .child(this.tag(k.status, k.status === "running" ? t.working : k.status === "done" ? t.ansi2 : t.dim))
      .child(div().flex_1().min_w(0).truncate().text_size(12).child(k.slug))
      .child(div().flex_none().text_size(11).text_color(t.dim).child(steps[k.slug]?.step ?? ""))));
  }

  // What an unfolded card adds: the row's other lines, its detail, links, actions.
  more(row, i, t) {
    const d = row.detail ?? {};
    const rest = row.lines.slice(row.key?.startsWith("proposal:") ? 3 : 2);
    const prop = d.body !== undefined ? proposalParts(d.body) : null;
    const slug = row.job?.slug ?? (row.key?.startsWith("workspace:") ? null : row.key?.startsWith("job:") ? row.key.slice(4) : null);
    const space = (slug || row.key?.startsWith("workspace:")) && spaces().find((s) => s.named && s.name === (slug ?? row.key.slice(10)));
    const actions = row.actions ?? [];
    const links = [
      ...(space ? [this.button(`go-${i}`, "Go to space", t, () => { run("space.select", { id: space.id }); closeOverlay(props().overlay); })] : []),
      ...(row.url ? [this.button(`url-${i}`, row.url.includes("github.com") ? "Open on GitHub" : "Open", t, () => exec("open", [row.url]))] : []),
      ...(slug ? [this.button(`rec-${i}`, "Job record", t, () => openOverlay({ mod: "glados-job", kind: "popup", width: 0.75, height: 0.85, props: { slug } }))] : []),
    ];
    return v_flex().gap(6).pl(18)
      .children(d.text !== undefined ? [] : rest.filter((l) => !/[█░]/.test(l.text)).map((l) => this.text(l.text, TONES(t)[l.tone] ?? t.muted)))
      .when(d.text !== undefined, (el) => el.child(this.text(d.text, t.foreground)))
      .when(Boolean(prop), (el) => el.children(prop.kv.map(([k, v]) => this.field(k, v, t)))
        .when(Boolean(prop.diff), (el) => el.child(this.fold(`diff:${row.key}`, "diff", () => this.mono(prop.diff, t), t))))
      .when(d.repo !== undefined, (el) => el.child(this.pr(d, t)))
      .when(Boolean(d.gate), (el) => el.child(this.fold(`gate:${row.key}`, `gate ${row.job?.gate ?? ""}`, () => this.text(d.gate, t.foreground), t)))
      .when(Boolean(d.kids), (el) => el.child(this.kids(d, t)))
      .when(d.path !== undefined, (el) => el.child(this.text(d.path ?? "", t.dim)))
      .when(links.length > 0 || actions.length > 0, (el) => el.child(h_flex().pt(2).gap(6).flex_wrap()
        .children(links)
        .children(actions.map((a, n) => {
          const armed = this.armed === a.post;
          return div().id(`act-${i}-${n}`).px(8).py(2).rounded(5).border_1().text_size(12)
            .border_color(armed ? t.blocked : t.border).text_color(armed ? t.blocked : t.muted)
            .hover((s) => s.bg(t.raised))
            .on_click((_e, cx) => { cx.stop_propagation(); this.act(a, cx); })
            .child(armed ? `${a.label}? click again` : a.label);
        }))));
  }

  // Folded: the row's first two lines (a proposal's title too), one line each.
  card(row, i, t) {
    const key = `card:${row.key ?? i}`;
    const open = this.open.has(key);
    const main = row.lines.slice(0, row.key?.startsWith("proposal:") ? 3 : 2);
    const line = (l, n) => div().when(!open, (el) => el.truncate()).when(open, (el) => el.whitespace_normal())
      .text_size(n ? 12 : 13).when(!n, (el) => el.font_semibold())
      .text_color(TONES(t)[l.tone] ?? (n ? t.muted : t.foreground)).child(l.text || " ");
    return v_flex().id(`card-${i}`).gap(6).px(10).py(8).rounded(8).border_1().border_color(open ? t.input : t.border).bg(t.background)
      .child(h_flex().id(`head-${i}`).gap(8).items_start().cursor_pointer()
        .on_click((_e, cx) => this.toggle(key, cx))
        .child(div().w(10).flex_none().text_color(t.dim).child(open ? "▾" : "▸"))
        .child(v_flex().flex_1().min_w(0).children(main.map(line))))
      .when(open, (el) => el.child(this.more(row, i, t)));
  }

  render() {
    const t = theme();
    const sec = (shared("factory.feed")?.sections ?? []).find((s) => s.name === props()?.only);
    return v_flex().id("root").w_full().h(window.viewport_size().height * 0.7).bg(t.canvas).text_size(13).text_color(t.foreground)
      .child(v_flex().id("cards").flex_1().min_h(0).overflow_y_scrollbar().p(10).gap(6)
        .when(!sec, (el) => el.child(this.text("nothing here now", t.dim)))
        .children((sec?.rows ?? []).map((row, i) => this.card(row, i, t))));
  }
}
