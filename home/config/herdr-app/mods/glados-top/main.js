// The factory feed as the window's top bar: the Productive inbox's unread count (opening glados-notifications),
// a chip per section (opening glados-chip) and the usage line.

import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { theme, shared, openOverlay, exec } from "herdr";
import { loadInbox } from "./inbox.js";

const TONES = (t) => ({ dim: t.dim, red: t.ansi1, green: t.ansi2, yellow: t.ansi3, blue: t.ansi4, magenta: t.ansi5, purple: t.ansi5, cyan: t.ansi6 });

export default class GladosTop extends View {
  init(_props, cx) {
    this.inboxError = null;
    cx.spawn(async (cx) => {
      for (;;) {
        try {
          await loadInbox();
          this.inboxError = null;
        } catch (e) {
          this.inboxError = String(e.message ?? e);
        }
        cx.notify();
        await exec("sleep", ["60"]).catch(() => {});
      }
    });
  }

  render() {
    const t = theme();
    const f = shared("factory.feed");
    const unread = (shared("productive.inbox") ?? []).filter((n) => !n.read).length;
    return h_flex().id("root").size_full().pl(88).pr(12).gap(8).items_center().bg(t.chrome).text_size(12)
      .child(div().id("inbox").flex_none().px(6).py(1).rounded(5).border_1().border_color(t.border)
        .text_color(this.inboxError ? t.blocked : unread ? t.accent : t.muted)
        .cursor_pointer().hover((s) => s.bg(t.raised))
        .when(Boolean(this.inboxError), (el) => el.tooltip(this.inboxError))
        .on_click(() => openOverlay({ mod: "glados-notifications", kind: "popup", at: "pointer", width: 420, height: 0.7 }))
        .child(h_flex().gap(4).items_center()
          .child(svg("mods/glados-top/productive.svg").w(14).h(12).flex_none().text_color(this.inboxError ? t.blocked : unread ? t.accent : t.muted))
          .child(this.inboxError ? "!" : String(unread))))
      .when(!f, (el) => el.child(div().flex_none().text_color(t.dim).child("connecting…")))
      .children((f?.sections ?? []).filter((sec) => sec.name !== "running").map((sec) => div().id(`chip-${sec.name}`).flex_none()
        .px(6).py(1).rounded(5).border_1().border_color(t.border).text_color(sec.name === "needs attention" ? t.blocked : t.muted)
        .cursor_pointer().hover((s) => s.bg(t.raised))
        .on_click(() => openOverlay({ mod: "glados-chip", kind: "popup", at: "pointer", width: 560, height: 0.7, props: { only: sec.name } }))
        .child(`${sec.name} ${sec.rows.length}`)))
      .child(div().id("numbers").flex_none().px(6).py(1).rounded(5).border_1().border_color(t.border).text_color(t.muted)
        .cursor_pointer().hover((s) => s.bg(t.raised))
        .on_click(() => openOverlay({ mod: "glados-numbers", kind: "popup", at: "pointer", width: 600, height: 0.8 }))
        .child("numbers"))
      .child(div().flex_1())
      .children((f?.foot ?? []).map((spans) => h_flex().flex_none().gap(4)
        .children(spans.map((s) => div().text_color(TONES(t)[s.tone] ?? t.muted).child(s.text.replace("resets in ", ""))))));
  }
}
