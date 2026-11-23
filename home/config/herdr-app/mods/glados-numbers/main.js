// The factory's numbers as a popup, opened from the top bar's numbers chip: today's tokens, the last
// 14 days as columns, job and PR totals, and the week's ledger and soak checks as bars.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { theme } from "herdr";

const BASE = "http://bestija-v4:4281";
const total = (parts) => parts.reduce((a, [v]) => a + (v ?? 0), 0);
const tok = (x) => (x >= 1e6 ? `${(x / 1e6).toFixed(1)}M` : x >= 1e3 ? `${Math.round(x / 1e3)}k` : String(x ?? 0));
const MODELS = (t) => ({ opus: t.ansi5, sonnet: t.ansi4, haiku: t.ansi6 });
const Y = 40;

// 0 up to the first round step (1, 2 or 5 × 10ⁿ, at least minStep) at or above max, about four steps.
function ticks(max, minStep) {
  const raw = Math.max(max, 1) / 4, mag = 10 ** Math.floor(Math.log10(raw));
  const step = Math.max(minStep, [1, 2, 5, 10].map((s) => s * mag).find((s) => s >= raw));
  return Array.from({ length: Math.max(1, Math.ceil(max / step)) + 1 }, (_, i) => i * step);
}

export default class GladosNumbers extends View {
  init(_props, cx) {
    this.n = null;
    cx.spawn(async (cx) => {
      try {
        const r = await fetch(`${BASE}/state`);
        this.n = r.ok ? (await r.json()).numbers : { error: `${r.status} on /state` };
      } catch (e) {
        this.n = { error: `can't reach ${BASE}` };
      }
      cx.notify();
    });
  }

  card(title, body, t) {
    return v_flex().gap(10).p(12).rounded(8).border_1().border_color(t.border).bg(t.background)
      .child(div().text_size(11).font_semibold().text_color(t.dim).child(title.toUpperCase()))
      .child(body);
  }

  bar(parts, max, t, h = 8) {
    return h_flex().w_full().h(h).rounded(h / 2).bg(t.raised).overflow_hidden()
      .children(parts.filter(([v]) => v > 0).map(([v, c]) => div().h_full().w(`${(100 * v) / Math.max(1, max)}%`).bg(c)));
  }

  legend(items, t) {
    return h_flex().gap(10).flex_wrap().children(items.map(([label, c]) => h_flex().gap(4).items_center()
      .child(div().size(8).rounded(2).bg(c))
      .child(div().text_size(11).text_color(t.muted).child(label))));
  }

  big(value, label, color, t, size = 22) {
    return v_flex().gap(1)
      .child(div().text_size(size).font_semibold().text_color(color).child(String(value)))
      .child(div().text_size(11).text_color(t.dim).child(label));
  }

  tile(value, label, color, t) {
    return div().flex_1().min_w(0).px(10).py(8).rounded(6).bg(t.chrome).child(this.big(value ?? 0, label, value ? color : t.dim, t));
  }

  // One column per day, oldest left, stacked from parts(day), over a y axis of round ticks with gridlines.
  columns(id, days, parts, tip, fmt, t, h, minStep = 0) {
    const ys = ticks(Math.max(...days.map((d) => total(parts(d)))), minStep), top = ys.at(-1);
    const at = (v) => (h * v) / top;
    return h_flex().gap(6)
      .child(div().relative().w(Y - 6).flex_none().h(h)
        .children(ys.filter((v) => v > 0).map((v) => div().absolute().right(0).bottom(at(v) - 7).text_size(10).text_color(t.dim).child(fmt(v)))))
      .child(div().relative().flex_1().h(h)
        .children(ys.map((v) => div().absolute().left(0).right(0).bottom(at(v)).h(1).bg(t.border)))
        .child(h_flex().absolute().inset_0().items_end().gap(3).children(days.map((d, i) => v_flex().id(`${id}-${i}`).flex_1().h_full().justify_end()
          .tooltip(`${d.day} · ${tip(d)}`)
          .children(parts(d).filter(([v]) => v > 0).reverse().map(([v, c], n) => div().w_full().h(Math.max(2, at(v))).bg(c)
            .when(n === 0, (el) => el.rounded_t(3))))))));
  }

  axis(days, t) {
    const today = days.at(-1)?.day;
    return h_flex().pl(Y).gap(3).children(days.map((d) => {
      const date = new Date(`${d.day}T00:00:00`);
      const weekend = date.getDay() === 0 || date.getDay() === 6;
      return div().flex_1().text_center().text_size(10).text_color(d.day === today ? t.foreground : weekend ? t.dim : t.muted)
        .when(d.day === today, (el) => el.font_semibold()).child(String(date.getDate()));
    }));
  }

  today(n, t) {
    const d = n.days[0], m = MODELS(t);
    const parts = Object.entries(d.tokens).sort((a, b) => b[1] - a[1]).map(([k, v]) => [v, m[k] ?? t.dim, k]);
    return this.card("Today", v_flex().gap(10)
      .child(h_flex().gap(16).items_end()
        .child(div().flex_1().child(this.big(tok(total(parts)), "tokens", t.foreground, t, 32)))
        .child(this.big(d.jobs.done ?? 0, "jobs done", t.ansi2, t))
        .child(this.big(d.jobs.merged ?? 0, "PRs merged", t.ansi3, t))
        .child(this.big(d.steps.done ?? 0, "steps done", t.foreground, t))
        .child(this.big(d.steps.failed ?? 0, "failed", d.steps.failed ? t.ansi1 : t.dim, t)))
      .child(this.bar(parts, total(parts), t, 10))
      .child(this.legend(parts.map(([v, c, k]) => [`${k} ${tok(v)}`, c]), t)), t);
  }

  fortnight(n, t) {
    const days = [...n.days].reverse(), m = MODELS(t);
    const models = [...new Set(days.flatMap((d) => Object.keys(d.tokens)))];
    const tokens = (d) => models.map((k) => [d.tokens[k] ?? 0, m[k] ?? t.dim]);
    const shipped = (d) => [[d.jobs.done ?? 0, t.ansi2], [d.jobs.merged ?? 0, t.ansi3]];
    const label = (s) => div().pb(4).text_size(11).text_color(t.muted).child(s);
    const mil = (v) => (v >= 1e6 ? `${+(v / 1e6).toFixed(1)}M` : tok(v));
    return this.card("Last 14 days", v_flex().gap(8)
      .child(label("tokens"))
      .child(this.columns("tok", days, tokens, (d) => models.map((k) => `${k} ${tok(d.tokens[k] ?? 0)}`).join(" · "), mil, t, 110))
      .child(div().pt(8).child(label("shipped")))
      .child(this.columns("ship", days, shipped, (d) => `${d.jobs.done ?? 0} jobs done · ${d.jobs.merged ?? 0} PRs merged`, String, t, 60, 1))
      .child(this.axis(days, t))
      .child(this.legend([...models.map((k) => [k, m[k] ?? t.dim]), ["jobs done", t.ansi2], ["PRs merged", t.ansi3]], t)), t);
  }

  totals(n, t) {
    return v_flex().gap(10)
      .child(this.card("Jobs", h_flex().gap(6)
        .child(this.tile(n.jobs.running, "running", t.working, t))
        .child(this.tile(n.jobs.done, "done", t.ansi2, t))
        .child(this.tile(n.jobs.parked, "parked", t.ansi3, t))
        .child(this.tile(n.jobs.closed, "closed", t.muted, t)), t))
      .child(this.card("PRs", h_flex().gap(6)
        .child(this.tile(n.prs.OPEN, "open", t.ansi4, t))
        .child(this.tile(n.prs.MERGED, "merged", t.ansi5, t))
        .child(this.tile(n.prs.unregistered, "no job", t.ansi3, t))
        .child(this.tile(n.prs.CLOSED, "closed", t.muted, t)), t));
  }

  ledger(n, t) {
    const C = [["done", t.ansi2], ["failed", t.ansi1], ["running", t.working], ["skipped", t.dim]];
    const max = Math.max(1, ...n.steps.map(([, s]) => total(C.map(([k]) => [s[k]]))));
    const soaks = [[n.soaks.clean ?? 0, t.ansi2], [n.soaks.signal ?? 0, t.ansi3], [n.soaks.error ?? 0, t.ansi1]];
    return this.card("Last 7 days", v_flex().gap(5)
      .children(n.steps.map(([step, s]) => h_flex().gap(8).items_center()
        .child(div().w(100).flex_none().truncate().text_size(12).text_color(t.muted).child(step))
        .child(div().flex_1().child(h_flex().w(`${(100 * total(C.map(([k]) => [s[k]]))) / max}%`).h(8).rounded(4).overflow_hidden()
          .children(C.filter(([k]) => s[k]).map(([k, c]) => div().h_full().w(`${(100 * s[k]) / total(C.map(([x]) => [s[x]]))}%`).bg(c)))))
        .child(h_flex().w(56).flex_none().justify_end().gap(6).text_size(12)
          .child(div().text_color(t.foreground).child(String(s.done ?? 0)))
          .when(Boolean(s.failed), (el) => el.child(div().text_color(t.ansi1).child(`✕${s.failed}`))))))
      .child(h_flex().pt(8).gap(8).items_center()
        .child(div().w(100).flex_none().text_size(12).text_color(t.muted).child("soak checks"))
        .child(div().flex_1().child(this.bar(soaks, total(soaks), t, 8)))
        .child(div().w(56).flex_none().text_right().text_size(12).text_color(t.foreground).child(`${n.soaks.clean ?? 0}/${total(soaks)}`)))
      .child(div().pt(6).child(this.legend([...C, ["soak signal", t.ansi3]], t))), t);
  }

  render() {
    const t = theme(), n = this.n;
    return v_flex().id("root").w_full().h(window.viewport_size().height * 0.8).bg(t.canvas).text_color(t.foreground)
      .child(v_flex().id("body").flex_1().min_h(0).overflow_y_scrollbar().p(10).gap(10)
        .when(!n, (el) => el.child(div().text_size(12).text_color(t.dim).child("loading…")))
        .when(Boolean(n?.error), (el) => el.child(div().text_size(12).text_color(t.blocked).child(n.error)))
        .when(Boolean(n && !n.error), (el) => el
          .child(this.today(n, t))
          .child(this.fortnight(n, t))
          .child(this.totals(n, t))
          .child(this.ledger(n, t))));
  }
}
