// Productive inbox notifications as a popup from the glados-top count (which polls them into
// shared "productive.inbox"); a task one opens glados-productive on it and marks it read.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, theme, props, shared, setShared, closeOverlay, openOverlay, notify } from "herdr";

const API = "https://api.productive.io/api/v2";

function ago(iso) {
  const m = Math.round((Date.now() - Date.parse(iso)) / 60000);
  return m < 60 ? `${m}m ago` : m < 1440 ? `${Math.round(m / 60)}h ago` : `${Math.round(m / 1440)}d ago`;
}

let token = null;

async function patch(id, action) {
  if (!token) {
    const key = await exec("security", ["find-generic-password", "-a", "productive", "-s", "PRODUCTIVE_AUTH_TOKEN", "-w"]);
    if (key.code !== 0) throw new Error("PRODUCTIVE_AUTH_TOKEN is not in the keychain (run /secrets)");
    token = key.stdout.trim();
  }
  const r = await fetch(`${API}/notifications/${id}/${action}`, { method: "PATCH", headers: { "X-Auth-Token": token, "X-Organization-Id": "109" } });
  if (!r.ok && r.status !== 409) throw new Error(`${r.status} on /notifications/${id}/${action}`);
}

const failed = (e) => notify({ title: "Notifications", body: String(e.message ?? e), level: "error" });

export default class Notifications extends View {
  archive(n, cx) {
    setShared("productive.inbox", (shared("productive.inbox") ?? []).filter((x) => x.id !== n.id));
    cx.spawn(() => patch(n.id, "dismiss").catch(failed));
  }

  open(n, cx) {
    if (!n.read) setShared("productive.inbox", (shared("productive.inbox") ?? []).map((x) => (x.id === n.id ? { ...x, read: true } : x)));
    cx.spawn(async () => {
      if (!n.read) await patch(n.id, "read").catch(failed);
      if (!n.task) return;
      closeOverlay(props().overlay);
      openOverlay({ mod: "glados-productive", kind: "dialog", width: 0.7, height: 0.85, props: { task: n.task } });
    });
  }

  row(n, t) {
    return h_flex().id(`n-${n.id}`).gap(8).px(10).py(8).rounded(8).items_start()
      .border_1().border_color(n.read ? t.border : t.input).bg(t.background)
      .when(Boolean(n.task) || !n.read, (el) => el.cursor_pointer().hover((s) => s.border_color(t.accent)).on_click((_e, cx) => this.open(n, cx)))
      .child(div().mt(5).size(7).flex_none().rounded(4).when(!n.read, (el) => el.bg(t.accent)))
      .child(v_flex().flex_1().min_w(0).gap(2)
        .child(h_flex().flex_wrap().gap_x(4).text_size(12)
          .when(Boolean(n.actor), (el) => el.child(div().text_color(t.muted).font_semibold().child(n.actor)))
          .child(div().text_color(t.dim).child(n.action)))
        .when(Boolean(n.item), (el) => el.child(div().whitespace_normal().text_color(n.read ? t.muted : t.foreground).when(!n.read, (el) => el.font_semibold())
          .child(n.item)))
        .when(Boolean(n.excerpt), (el) => el.child(div().truncate().text_size(12).text_color(t.dim).child(n.excerpt)))
        .child(h_flex().gap(6).text_size(11).text_color(t.dim)
          .when(Boolean(n.project), (el) => el.child(div().min_w(0).truncate().text_color(t.ansi4).child(n.project)).child("·"))
          .child(div().flex_none().child(ago(n.at)))))
      .child(div().id(`a-${n.id}`).flex_none().text_color(t.dim).cursor_pointer().hover((s) => s.text_color(t.accent)).tooltip("Archive")
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click((_e, cx) => { cx.stop_propagation(); this.archive(n, cx); })
        .child(svg("mods/glados-chrome/archive.svg").size(14)));
  }

  render() {
    const t = theme();
    const items = shared("productive.inbox");
    return v_flex().id("root").w_full().h(window.viewport_size().height * 0.7).bg(t.canvas).text_size(13).text_color(t.foreground)
      .child(v_flex().id("list").flex_1().min_h(0).overflow_y_scrollbar().p(10).gap(6)
        .when(!items, (el) => el.child(div().p(10).text_color(t.dim).child("loading…")))
        .when(items?.length === 0, (el) => el.child(div().p(10).text_color(t.dim).child("inbox zero")))
        .children((items ?? []).map((n) => this.row(n, t))));
  }
}
