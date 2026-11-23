// Productive tasks as a dialog, drawn after fantastic-productive's My tasks and task panel.
// Toggled with mod.open (keys.json); props {task?} opens it on that task, else on the index.

import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, TextView, InputState, Input, TextareaState, Textarea } from "gpui-base";
import { exec, theme, props, notify, shared, setShared, appHome, readTextFile, writeTextFile } from "herdr";
import { htmlToMarkdown, markdownToHtml } from "./markdown.js";
import { feed } from "./activity.js";

const API = "https://api.productive.io/api/v2";
const ORG = "109";
const WEB = "https://app.productive.io/109-productive";
const PALETTE = ["#ffe500", "#ff784b", "#e03e74", "#8ccf3e", "#55c9fb", "#8554d4", "#cd6296", "#4f6bf8", "#42dad1", "#828282",
  "#8085b7", "#ffc837", "#4994fd", "#ff6666", "#21d191", "#1ec9e8", "#ffffff"];
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const ICON = (name) => `mods/glados-productive/${name}.svg`;
const CHROME = (name) => `mods/glados-chrome/${name}.svg`;
const AVATARS = "data/glados-productive/avatars";

const query = (params) => Object.entries(params).map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`).join("&");

function statusColor(s, t) {
  if (!s) return t.dim;
  return PALETTE[Number(s.color_id)] ?? (s.category_id === 3 ? "#21d191" : s.category_id === 1 ? t.muted : t.accent);
}

function day(iso) {
  const [y, m, d] = iso.split("-").map(Number);
  return { date: new Date(y, m - 1, d), label: `${d} ${MONTHS[m - 1]}${y === new Date().getFullYear() ? "" : ` ${y}`}` };
}

function minutes(n) {
  if (!n) return null;
  const h = Math.floor(n / 60), m = n % 60;
  return [h && `${h}h`, m && `${m}m`].filter(Boolean).join(" ");
}

function ago(iso) {
  const m = Math.round((Date.now() - Date.parse(iso)) / 60000);
  return m < 60 ? `${m}m ago` : m < 1440 ? `${Math.round(m / 60)}h ago` : m < 43200 ? `${Math.round(m / 1440)}d ago` : day(iso.slice(0, 10)).label;
}

const iso = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;

function parseDate(s) {
  const t = s.trim().toLowerCase();
  if (!t) return null;
  const now = new Date();
  const plus = (days) => iso(new Date(now.getFullYear(), now.getMonth(), now.getDate() + days));
  if (t === "today") return plus(0);
  if (t === "tomorrow") return plus(1);
  let m = t.match(/^\+(\d+)\s*([dw]?)$/);
  if (m) return plus(+m[1] * (m[2] === "w" ? 7 : 1));
  if (/^\d{4}-\d{2}-\d{2}$/.test(t)) return t;
  m = t.match(/^(\d{1,2})\.(\d{1,2})\.?(\d{4})?$/);
  if (m) return iso(new Date(+(m[3] ?? now.getFullYear()), +m[2] - 1, +m[1]));
  return undefined;
}

function parseMinutes(s) {
  const t = s.trim().toLowerCase();
  if (!t) return null;
  const m = t.match(/^(?:(\d+(?:\.\d+)?)\s*h)?\s*(?:(\d+)\s*m?)?$/);
  if (!m || (!m[1] && !m[2])) return undefined;
  return Math.round((Number(m[1] ?? 0) * 60) + Number(m[2] ?? 0));
}

const name = (p) => (p ? [p.first_name, p.last_name].filter(Boolean).join(" ") : null);
const initials = (n) => (n ?? "?").split(" ").map((w) => w[0]).slice(0, 2).join("").toUpperCase();

export default class Productive extends View {
  init(_props, cx) {
    this.stack = props()?.task ? [String(props().task)] : [];
    const cache = shared("productive.cache") ?? {};
    this.tasks = cache.tasks ?? null;
    this.detail = cache.detail ?? {};
    this.loading = 0;
    this.folded = new Set(shared("productive.folded") ?? []);
    this.handle = cx.focus_handle();
    this.handle.focus();
    cx.timer.after(600, () => { if (!this.typing) this.handle.focus(); });
    this.typing = false;
    this.error = null;
    this.width = 800;
    this.picker = null;
    this.statuses = {};
    this.people = [];
    this.editing = null;
    this.feedFilter = "all";
    this.avatars = {};
    this.fields = {};
    this.person = cache.me ?? null;
    this.comment = this.textarea("Write a comment… (markdown, ⌘↩ to post)", 2, 12, (cx) => this.addComment(cx));
    this.draft = this.textarea("", 6, 30, (cx) => this.saveEdit(cx));
    this.line = InputState.new({});
    this.line.on("submit", (_e, cx) => this.saveEdit(cx));
    this.todo = this.input("Add a to-do…", (text, cx) => this.addTodo(text, cx));
    this.search = InputState.new({ placeholder: "Search people…" });
    this.search.on("change", (_e, cx) => this.findPeople(this.search.value(), cx));
    this.searching = false;
    this.allStatuses = false;
    this.results = null;
    this.seq = 0;
    this.find = InputState.new({ placeholder: "Search all tasks…" });
    this.find.on("change", (_e, cx) => this.findTasks(this.find.value(), cx));
    for (const state of [this.comment, this.draft, this.line, this.todo, this.search, this.find]) {
      state.on("focus", () => { this.typing = true; this.focusedState = state; });
      state.on("blur", () => { this.typing = false; });
    }
    cx.spawn(async (cx) => {
      const path = `${appHome()}/data/glados-productive/open`;
      const pending = await readTextFile(path).catch(() => null);
      if (pending?.trim()) {
        this.stack = [pending.trim()];
        await writeTextFile(path, "", pending).catch(() => null);
      }
      this.load(cx);
    });
  }

  textarea(placeholder, min, max, onSubmit) {
    const state = TextareaState.new({ placeholder });
    state.set_auto_grow(min, max);
    state.on("submit", (_e, cx) => onSubmit(cx));
    return state;
  }

  input(placeholder, onSubmit) {
    const state = InputState.new({ placeholder });
    state.on("submit", (_e, cx) => {
      const text = state.value().trim();
      if (!text) return;
      state.set_value("");
      onSubmit(text, cx);
    });
    return state;
  }

  async headers() {
    if (!this.token) {
      const r = await exec("security", ["find-generic-password", "-a", "productive", "-s", "PRODUCTIVE_AUTH_TOKEN", "-w"]);
      if (r.code !== 0) throw new Error("PRODUCTIVE_AUTH_TOKEN is not in the keychain (run /secrets)");
      this.token = r.stdout.trim();
    }
    return { "X-Auth-Token": this.token, "X-Organization-Id": ORG, "Content-Type": "application/vnd.api+json" };
  }

  async send(method, path, data) {
    const r = await fetch(`${API}${path}`, { method, headers: await this.headers(), ...(data && { body: JSON.stringify({ data }) }) });
    if (!r.ok) throw new Error(`${r.status} on ${method} ${path}: ${(await r.text()).slice(0, 200)}`);
  }

  write(cx, method, path, data) {
    cx.spawn(async (cx) => {
      try {
        await this.send(method, path, data);
      } catch (e) {
        notify({ title: "Productive", body: String(e.message ?? e), level: "error" });
      }
      this.load(cx);
    });
  }

  async api(path, params = {}) {
    const r = await fetch(`${API}${path}?${query(params)}`, { headers: await this.headers() });
    if (!r.ok) throw new Error(`${r.status} on ${path}`);
    const body = await r.json();
    const inc = new Map((body.included ?? []).map((x) => [`${x.type}:${x.id}`, { id: x.id, ...x.attributes, rel: x.relationships }]));
    const one = (x, key) => {
      const d = x?.relationships?.[key]?.data ?? x?.rel?.[key]?.data;
      return d && inc.get(`${d.type}:${d.id}`);
    };
    const many = (x, key) => (x?.relationships?.[key]?.data ?? []).map((d) => inc.get(`${d.type}:${d.id}`)).filter(Boolean);
    return { body, one, many };
  }

  async me() {
    if (this.person) return this.person;
    const { body } = await this.api("/organization_memberships", { include: "organization,person" });
    this.person = body.data.find((m) => m.relationships.organization.data?.id === ORG)?.relationships.person.data.id;
    return this.person;
  }

  avatarPath(url) {
    let h = 5381;
    for (const ch of url) h = ((h << 5) + h + ch.charCodeAt(0)) >>> 0;
    const ext = url.split("?")[0].match(/\.(jpe?g|png|gif|webp)$/i)?.[1] ?? "png";
    return `${AVATARS}/${h.toString(36)}.${ext.toLowerCase()}`;
  }

  fetchAvatars(urls, cx) {
    const todo = [...new Set(urls.filter(Boolean))].filter((u) => !this.avatars[u]);
    if (!todo.length) return;
    for (const u of todo) this.avatars[u] = "loading";
    const script = 'cd "$0" && mkdir -p "$1" && shift && while [ $# -gt 0 ]; do [ -s "$1" ] || curl -sfL --max-time 10 -o "$1" "$2"; [ -s "$1" ] && echo "$1"; shift 2; done';
    cx.spawn(async (cx) => {
      const r = await exec("sh", ["-c", script, appHome(), AVATARS, ...todo.flatMap((u) => [this.avatarPath(u), u])]).catch(() => null);
      const ready = new Set((r?.stdout ?? "").split("\n"));
      for (const u of todo) this.avatars[u] = ready.has(this.avatarPath(u)) ? "ready" : "failed";
      cx.notify();
    });
  }

  avatar(url, label, size, t) {
    if (url && this.avatars[url] === "ready") return image(this.avatarPath(url)).size(size).flex_none().rounded_full();
    return div().size(size).flex_none().rounded_full().bg(t.raised).flex().items_center().justify_center()
      .text_size(Math.round(size * 0.42)).font_semibold().text_color(t.muted).child(initials(label));
  }

  load(cx) {
    const id = this.stack.at(-1);
    this.loading++;
    cx.spawn(async (cx) => {
      try {
        if (id) this.detail[id] = { ...(await this.fetchTask(id)), seen: Date.now() };
        else this.tasks = await this.fetchTasks();
        this.error = null;
        this.save();
        if (id && this.picker === "status") this.loadStatuses(this.detail[id], cx);
        if (id) this.fetchAvatars([this.detail[id].assigneeAvatar, ...this.detail[id].feed.map((r) => r.avatar)], cx);
      } catch (e) {
        this.error = String(e.message ?? e);
      }
      this.loading--;
      cx.notify();
    });
  }

  // ponytail: whole cache rewritten into shared.json on every fetch; the 40 most recently seen tasks keep their detail.
  save() {
    const kept = Object.entries(this.detail).sort(([, a], [, b]) => (b.seen ?? 0) - (a.seen ?? 0)).slice(0, 40);
    this.detail = Object.fromEntries(kept);
    setShared("productive.cache", { tasks: this.tasks, detail: this.detail, me: this.person });
  }

  row(task, one) {
    const a = task.attributes ?? task;
    const s = one(task, "workflow_status");
    const status = s && { id: s.id, name: s.name, color_id: s.color_id, category_id: s.category_id };
    return {
      id: task.id, number: a.task_number, title: a.title, closed: a.closed, due: a.due_date,
      project: one(task, "project")?.name ?? "No project", status,
      todos: a.todo_count ?? 0, openTodos: a.open_todo_count ?? 0, subtasks: a.subtask_count ?? 0,
    };
  }

  async fetchTasks() {
    const me = await this.me();
    const { body, one } = await this.api("/tasks", {
      "filter[assignee_id]": me, "filter[status]": 1, include: "project,workflow_status", "page[size]": 200, sort: "-updated_at",
    });
    return body.data.map((task) => this.row(task, one));
  }

  async fetchTask(id) {
    const [task, activities] = await Promise.all([
      this.api(`/tasks/${id}`, { include: "project,task_list,task_list.folder,workflow_status,workflow_status.workflow,assignee,subtasks,subtasks.workflow_status,todos,custom_field_people" }),
      this.api("/activities", { "filter[task_id]": id, include: "creator,comment", "page[size]": 200 }),
      this.me(),
    ]);
    const { body, one, many } = task;
    const list = one(body.data, "task_list");
    const project = one(body.data, "project");
    return {
      ...this.row(body.data, one),
      projectId: project?.id,
      listId: list?.id,
      values: body.data.attributes.custom_fields ?? {},
      people: Object.fromEntries(many(body.data, "custom_field_people").map((p) => [p.id, name(p)])),
      fields: await this.fieldDefs(project),
      description: body.data.attributes.description,
      start: body.data.attributes.start_date,
      estimate: body.data.attributes.initial_estimate,
      worked: body.data.attributes.worked_time,
      assignee: name(one(body.data, "assignee")),
      assigneeId: one(body.data, "assignee")?.id,
      assigneeAvatar: one(body.data, "assignee")?.avatar_url,
      workflow: one(body.data, "workflow_status")?.rel?.workflow?.data?.id,
      list: list?.name,
      folder: one(list, "folder")?.name,
      subtaskRows: many(body.data, "subtasks").map((s) => ({ ...this.row(s, one), id: s.id })),
      todoRows: many(body.data, "todos").sort((x, y) => (x.position ?? 0) - (y.position ?? 0))
        .map((x) => ({ id: x.id, description: x.description, closed: x.closed })),
      feed: feed(activities.body.data.flatMap((a) => {
        const c = activities.one(a, "comment");
        if (a.attributes.item_type === "comment" && (!c || c.deleted_at || c.hidden || c.draft)) return [];
        const creator = activities.one(a, "creator");
        return [{
          id: a.id, at: a.attributes.created_at, creatorId: creator?.id,
          author: a.attributes.made_by_automation ? "Automation" : name(creator) ?? a.attributes.external_author_name,
          avatar: a.attributes.made_by_automation ? null : creator?.avatar_url,
          comment: c && { id: c.id, body: c.body }, raw: { attributes: a.attributes },
        }];
      }), id),
    };
  }

  async fieldDefs(project) {
    const ids = project?.task_custom_fields_ids ?? [];
    if (!ids.length) return [];
    const key = ids.join(",");
    if (!this.fields[key]) {
      const { body, many } = await this.api("/custom_fields", { "filter[id]": key, include: "options", "page[size]": 100 });
      const pos = project.task_custom_fields_positions ?? {};
      this.fields[key] = body.data
        .filter((f) => !f.attributes.archived && f.attributes.data_type_id !== 7)
        .map((f) => ({ id: f.id, name: f.attributes.name, type: f.attributes.data_type_id, options: many(f, "options").filter((o) => !o.archived_at).sort((x, y) => (x.position ?? 0) - (y.position ?? 0)).map((o) => ({ id: o.id, name: o.name })) }))
        .sort((a, b) => (pos[a.id] ?? 999) - (pos[b.id] ?? 999));
    }
    return this.fields[key];
  }

  open(id, cx) {
    this.stack.push(String(id));
    this.picker = null;
    this.editing = null;
    this.load(cx);
    cx.notify();
  }

  back(cx) {
    this.stack.pop();
    this.picker = null;
    this.editing = null;
    this.load(cx);
    cx.notify();
  }

  shown() {
    const id = this.stack.at(-1);
    return id && this.detail[id];
  }

  link(url, cx) {
    const task = url.match(/productive\.io\/[^?#]*\/tasks?\/(?:task\/)?(\d+)/)?.[1];
    if (task) this.open(task, cx);
    else exec("open", [url]);
  }

  addComment(cx) {
    const d = this.shown();
    const text = this.comment.value().trim();
    if (!text) return;
    this.comment.set_value("");
    this.write(cx, "POST", "/comments", { type: "comments", attributes: { body: markdownToHtml(text) }, relationships: { task: { data: { type: "tasks", id: d.id } } } });
  }

  startEdit(edit, cx) {
    const d = this.shown();
    this.picker = null;
    this.editing = edit;
    const value = {
      title: d.title,
      due: d.due ?? "",
      start: d.start ?? "",
      estimate: minutes(d.estimate) ?? "",
      field: edit.field && String(d.values[edit.field.id] ?? ""),
    }[edit.kind];
    if (edit.kind === "description") this.draft.set_value(htmlToMarkdown(d.description));
    else if (edit.kind === "comment") this.draft.set_value(htmlToMarkdown(d.feed.find((r) => r.comment?.id === edit.id)?.comment.body));
    (edit.kind === "description" || edit.kind === "comment" ? this.draft : this.line).focus();
    if (value !== undefined) this.line.set_value(value);
    cx.notify();
  }

  cancelEdit(cx) {
    this.editing = null;
    this.handle.focus();
    cx.notify();
  }

  saveEdit(cx) {
    const d = this.shown();
    const edit = this.editing;
    if (!d || !edit) return;
    const text = (edit.kind === "description" || edit.kind === "comment" ? this.draft : this.line).value().trim();
    const task = (attributes) => this.write(cx, "PATCH", `/tasks/${d.id}`, { type: "tasks", id: d.id, attributes });
    const invalid = (what) => notify({ title: "Productive", body: `Can't read "${text}" as ${what}`, level: "warning" });
    switch (edit.kind) {
      case "title": if (text) task({ title: text }); break;
      case "description": task({ description: markdownToHtml(text) }); break;
      case "comment": this.write(cx, "PATCH", `/comments/${edit.id}`, { type: "comments", id: edit.id, attributes: { body: markdownToHtml(text) } }); break;
      case "due": case "start": {
        const date = parseDate(text);
        if (date === undefined) return invalid("a date");
        task({ [edit.kind === "due" ? "due_date" : "start_date"]: date });
        break;
      }
      case "estimate": {
        const n = parseMinutes(text);
        if (n === undefined) return invalid("a duration");
        task({ initial_estimate: n });
        break;
      }
      case "field": {
        let value = text || null;
        if (value && edit.field.type === 4 && !(value = parseDate(text))) return invalid("a date");
        if (value && (edit.field.type === 2 || edit.field.type === 8) && Number.isNaN(Number(value))) return invalid("a number");
        this.setField(edit.field, value, cx);
        break;
      }
    }
    this.editing = null;
    this.handle.focus();
    cx.notify();
  }

  setField(field, value, cx) {
    const d = this.shown();
    const values = { ...d.values };
    if (value == null || (Array.isArray(value) && !value.length)) delete values[field.id];
    else values[field.id] = value;
    d.values = values;
    this.picker = null;
    cx.notify();
    this.write(cx, "PATCH", `/tasks/${d.id}`, { type: "tasks", id: d.id, attributes: { custom_fields: values } });
  }

  async taskLists(projectId) {
    this.lists ??= {};
    if (!this.lists[projectId]) {
      const { body, one } = await this.api("/task_lists", { "filter[project_id]": projectId, "filter[status]": 1, include: "folder", "page[size]": 200 });
      this.lists[projectId] = body.data.map((l) => ({ id: l.id, name: [one(l, "folder")?.name, l.attributes.name].filter(Boolean).join(" › ") }));
    }
    return this.lists[projectId];
  }

  addTodo(text, cx) {
    const d = this.shown();
    d.todoRows.push({ id: `new-${Date.now()}`, description: text, closed: false });
    cx.notify();
    this.write(cx, "POST", "/todos", { type: "todos", attributes: { description: text }, relationships: { task: { data: { type: "tasks", id: d.id } } } });
  }

  toggleTodo(todo, cx) {
    if (todo.id.startsWith("new-")) return;
    todo.closed = !todo.closed;
    cx.notify();
    this.write(cx, "PATCH", `/todos/${todo.id}`, { type: "todos", id: todo.id, attributes: { closed: todo.closed } });
  }

  setTask(relationship, type, value, cx) {
    const d = this.shown();
    this.picker = null;
    cx.notify();
    this.write(cx, "PATCH", `/tasks/${d.id}`, { type: "tasks", id: d.id, relationships: { [relationship]: { data: value && { type, id: value } } } });
  }

  loadStatuses(d, cx) {
    if (!d.workflow || d.workflow in this.statuses) return;
    const workflow = d.workflow;
    this.statuses[workflow] = null;
    cx.spawn(async (cx) => {
      try {
        const { body } = await this.api("/workflow_statuses", { "filter[workflow_id]": workflow, "page[size]": 100 });
        this.statuses[workflow] = body.data.map((s) => ({ id: s.id, ...s.attributes })).sort((a, b) => a.category_id - b.category_id || (a.position ?? 0) - (b.position ?? 0));
      } catch (e) {
        delete this.statuses[workflow];
        notify({ title: "Productive", body: `Statuses: ${e.message ?? e}`, level: "error" });
      }
      cx.notify();
    });
  }

  togglePicker(which, cx, person = false) {
    this.picker = this.picker === which ? null : which;
    this.editing = null;
    const d = this.shown();
    if (this.picker === "list" && d.projectId && !this.lists?.[d.projectId])
      cx.spawn(async (cx) => {
        await this.taskLists(d.projectId);
        cx.notify();
      });
    if (this.picker === "status") this.loadStatuses(d, cx);
    if (this.picker && (this.picker === "assignee" || person)) {
      this.search.set_value("");
      this.people = [];
      this.search.focus();
    }
    cx.notify();
  }

  startSearch(cx) {
    this.searching = true;
    this.find.focus();
    cx.notify();
  }

  stopSearch(cx) {
    this.searching = false;
    this.results = null;
    this.find.set_value("");
    this.handle.focus();
    cx.notify();
  }

  findTasks(text, cx) {
    const seq = ++this.seq;
    if (text.trim().length < 2) {
      this.results = null;
      return cx.notify();
    }
    cx.timer.after(250, (cx) => {
      if (seq !== this.seq) return;
      this.loading++;
      cx.spawn(async (cx) => {
        try {
          const { body } = await this.api("/search/quick", { "filter[query]": text, "filter[type]": "task", ...(this.allStatuses && { "filter[status]": "all" }), "page[size]": 30 });
          if (seq === this.seq) this.results = body.data.map(({ attributes: a }) => {
            const title = a.title.replace(/<[^>]+>/g, "");
            return {
              id: a.record_id, number: title.match(/^#(\d+)/)?.[1], title: title.replace(/^#\d+\s*/, ""), closed: a.status !== "active",
              where: [a.meta?.project_name, a.meta?.task_list_name].filter(Boolean).join(" › "), status: a.meta?.workflow_status,
            };
          });
          this.error = null;
        } catch (e) {
          this.error = String(e.message ?? e);
        }
        this.loading--;
        cx.notify();
      });
    });
  }

  findPeople(text, cx) {
    if (text.trim().length < 2) {
      this.people = [];
      return cx.notify();
    }
    cx.spawn(async (cx) => {
      const { body } = await this.api("/people", { "filter[query]": text, "filter[status]": 1, "filter[person_type]": 1, "page[size]": 8 });
      if (this.search.value() !== text) return;
      this.people = body.data.map((p) => ({ id: p.id, name: name(p.attributes), avatar: p.attributes.avatar_url }));
      this.fetchAvatars(this.people.map((p) => p.avatar), cx);
      cx.notify();
    });
  }

  dot(status, t) {
    return div().size(10).flex_none().rounded_full().bg(statusColor(status, t));
  }

  due(iso, closed, t) {
    if (!iso) return null;
    const { date, label } = day(iso);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const color = closed ? t.muted : date < today ? t.ansi1 : date.getTime() === today.getTime() ? t.ansi3 : t.muted;
    return h_flex().flex_none().gap(4).items_center().text_size(12).text_color(color)
      .child(svg(ICON("calendar")).size(12))
      .child(date.getTime() === today.getTime() ? "Today" : label);
  }

  iconButton(id, icon, onClick, t) {
    return div().id(id).flex_none().p(4).rounded(5).text_color(t.muted).cursor_pointer()
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => onClick(cx))
      .child(svg(icon).size(14));
  }

  html(id, value, t) {
    return div().whitespace_normal().text_size(13).text_color(t.foreground)
      .child(TextView.html(id, value).selectable(true).on_link_click((url, cx) => this.link(url, cx)));
  }

  textInput(state, t) {
    return Input.new(state).h(32).px(10).rounded(7).border_1().border_color(t.input).bg(t.surface).text_size(13).text_color(t.foreground);
  }

  editable(id, value, active, onClick, t) {
    return div().id(id).px(6).py(3).rounded(6).cursor_pointer()
      .when(active, (el) => el.bg(t.selected))
      .hover((s) => s.bg(t.hover))
      .on_click((_e, cx) => onClick(cx))
      .child(value);
  }

  option(id, content, active, onClick, t) {
    return h_flex().id(id).gap(8).items_center().px(8).py(5).rounded(6).cursor_pointer()
      .when(active, (el) => el.bg(t.selected))
      .hover((s) => s.bg(t.hover))
      .on_click((_e, cx) => onClick(cx))
      .child(content);
  }

  statusPicker(d, t) {
    const list = this.statuses[d.workflow];
    return v_flex().mt(4).p(4).rounded(8).border_1().border_color(t.border).bg(t.popover)
      .when(!list, (el) => el.child(div().p(6).text_size(12).text_color(t.dim).child("loading…")))
      .children((list ?? []).map((s) => this.option(`st-${s.id}`,
        h_flex().gap(8).items_center().child(this.dot(s, t)).child(div().truncate().text_size(13).child(s.name)),
        s.id === d.status?.id, (cx) => this.setTask("workflow_status", "workflow_statuses", s.id, cx), t)));
  }

  popover(t) {
    return v_flex().mt(4).p(4).gap(2).rounded(8).border_1().border_color(t.border).bg(t.popover);
  }

  peoplePicker(current, onPick, t) {
    return this.popover(t)
      .child(this.textInput(this.search, t))
      .children(this.people.map((p) => this.option(`pp-${p.id}`, h_flex().gap(8).items_center().min_w(0).child(this.avatar(p.avatar, p.name, 20, t)).child(div().truncate().text_size(13).child(p.name)), p.id === current, (cx) => onPick(p.id, cx), t)))
      .when(Boolean(current), (el) => el.child(this.option("pp-none", div().text_size(13).text_color(t.muted).child("Clear"), false, (cx) => onPick(null, cx), t)));
  }

  listPicker(d, t) {
    const lists = this.lists?.[d.projectId];
    return v_flex().id("lists").max_h(260).overflow_y_scrollbar().mt(4).p(4).gap(2).rounded(8).border_1().border_color(t.border).bg(t.popover)
      .when(!lists, (el) => el.child(div().p(6).text_size(12).text_color(t.dim).child("loading…")))
      .children((lists ?? []).map((l) => this.option(`tl-${l.id}`, div().truncate().text_size(13).child(l.name), l.id === d.listId,
        (cx) => this.setTask("task_list", "task_lists", l.id, cx), t)));
  }

  optionsPicker(field, d, t) {
    const multi = field.type === 5;
    const current = [d.values[field.id] ?? []].flat().map(String);
    return v_flex().id(`opts-${field.id}`).max_h(260).overflow_y_scrollbar().mt(4).p(4).gap(2).rounded(8).border_1().border_color(t.border).bg(t.popover)
      .children(field.options.map((o) => this.option(`op-${o.id}`, div().truncate().text_size(13).child(o.name), current.includes(o.id), (cx) => {
        if (!multi) return this.setField(field, current.includes(o.id) ? null : o.id, cx);
        this.setField(field, current.includes(o.id) ? current.filter((x) => x !== o.id) : [...current, o.id], cx);
        this.picker = `field-${field.id}`;
      }, t)));
  }

  lineEditor(edit, t) {
    const dates = edit.kind === "due" || edit.kind === "start" || edit.field?.type === 4;
    const quick = (label, value) => div().id(`q-${label}`).px(6).py(1).rounded(5).text_size(11.5).text_color(t.muted).cursor_pointer()
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => { this.line.set_value(value); this.saveEdit(cx); })
      .child(label);
    return v_flex().gap(4)
      .child(this.textInput(this.line, t))
      .when(dates, (el) => el.child(h_flex().gap(2).flex_wrap()
        .child(quick("Today", "today")).child(quick("Tomorrow", "tomorrow")).child(quick("+1w", "+1w")).child(quick("Clear", ""))))
      .child(div().text_size(11).text_color(t.dim).child(dates ? "2026-11-20 · 20.11. · +3 · ↩ saves" : edit.kind === "estimate" ? "90 · 1h 30m · 1.5h · ↩ saves" : "↩ saves · esc cancels"));
  }

  textEditor(t, onSave) {
    const button = (id, label, primary, action) => div().id(id).px(10).py(4).rounded(6).text_size(12.5).cursor_pointer()
      .bg(primary ? t.solid : t.raised).text_color(primary ? t.solid_foreground : t.foreground)
      .hover((s) => s.opacity(0.88)).on_click((_e, cx) => action(cx)).child(label);
    return v_flex().gap(6)
      .child(div().p(8).rounded(7).border_1().border_color(t.accent).bg(t.surface).child(Textarea.new(this.draft).w_full().text_size(13).text_color(t.foreground)))
      .child(h_flex().gap(6).items_center()
        .child(div().flex_1().text_size(11).text_color(t.dim).child("Markdown · ⌘↩ saves · esc cancels"))
        .child(button("ed-cancel", "Cancel", false, (cx) => this.cancelEdit(cx)))
        .child(button("ed-save", "Save", true, onSave)));
  }

  status(t) {
    return h_flex().flex_none().gap(6).items_center()
      .when(this.loading > 0, (el) => el.child(svg(CHROME("spinner")).size(13).text_color(t.muted).spin(900)))
      .when(Boolean(this.error), (el) => el.child(div().max_w(260).truncate().text_size(11.5).text_color(t.ansi1).child(this.error)));
  }

  separator(t) {
    return div().h(1).flex_none().bg(t.border);
  }

  sectionHeader(label, count, t) {
    return h_flex().gap(6).items_center().pb(4)
      .child(div().text_size(12.5).font_semibold().text_color(t.foreground).child(label))
      .when(count != null, (el) => el.child(div().text_size(12).text_color(t.muted).child(String(count))));
  }

  taskRow(r, t, wide) {
    const counts = [r.subtasks > 0 && `${r.subtasks} sub`, r.todos > 0 && `${r.todos - r.openTodos}/${r.todos}`].filter(Boolean).join(" · ");
    return h_flex().id(`row-${r.id}`).gap(8).items_center().py(7).pl(6).pr(6).rounded(6).cursor_pointer()
      .hover((s) => s.bg(t.hover))
      .on_click((_e, cx) => this.open(r.id, cx))
      .child(this.dot(r.status, t))
      .when(wide && Boolean(r.number), (el) => el.child(div().w(40).flex_none().truncate().text_size(12).text_color(t.muted).child(r.number)))
      .child(div().flex_1().min_w(0).truncate().text_size(14).font_medium().text_color(r.closed ? t.muted : t.foreground).when(r.closed, (el) => el.line_through()).child(r.title))
      .when(wide, (el) => el.child(div().w(100).flex_none().truncate().text_size(12).text_color(t.muted).child(counts)))
      .child(h_flex().flex_none().justify_end().when(wide, (el) => el.w(70)).children([this.due(r.due, r.closed, t)].filter(Boolean)));
  }

  index(t) {
    const wide = this.width >= 576;
    const groups = new Map();
    for (const r of this.tasks ?? []) groups.set(r.project, [...(groups.get(r.project) ?? []), r]);
    const chip = (label, value) => h_flex().gap(5).items_center().px(8).py(3).rounded(6).bg(t.accent + "26").text_size(12)
      .child(div().text_color(t.muted).child(label)).child(div().text_color(t.foreground).child(value));
    return v_flex().size_full().min_h(0)
      .child(h_flex().flex_none().gap(8).items_center().px(14).py(10).border_b_1().border_color(t.border)
        .child(div().text_size(16).font_semibold().child("Tasks"))
        .child(div().text_size(12).text_color(t.muted).child(this.tasks ? String(this.tasks.length) : ""))
        .child(div().flex_1())
        .child(this.status(t))
        .child(this.iconButton("search", CHROME("search"), (cx) => this.startSearch(cx), t))
        .child(this.iconButton("web", ICON("external"), () => exec("open", [`${WEB}/tasks`]), t)))
      .child(h_flex().flex_none().gap(6).px(14).pt(10).flex_wrap().child(chip("Assignee", "Me")).child(chip("Status", "Open")))
      .child(v_flex().id("index").flex_1().min_h(0).overflow_y_scrollbar().px(10).py(10).gap(2)
        .when(!this.tasks, (el) => el.child(div().px(6).text_color(t.dim).child(this.error ?? "loading…")))
        .children([...groups].map(([project, rows]) => {
          const folded = this.folded.has(project);
          return v_flex()
            .child(h_flex().id(`g-${project}`).gap(6).items_center().px(4).py(6).rounded(6).cursor_pointer()
              .hover((s) => s.bg(t.hover))
              .on_click(() => {
                folded ? this.folded.delete(project) : this.folded.add(project);
                setShared("productive.folded", [...this.folded]);
              })
              .child(svg(CHROME(folded ? "chevron-right" : "chevron-down")).size(12).flex_none().text_color(t.muted))
              .child(div().flex_1().truncate().text_size(14).font_semibold().child(project))
              .child(div().text_size(12).text_color(t.muted).child(String(rows.length))))
            .when(!folded, (el) => el.child(v_flex().ml(10).pl(6).border_l_1().border_color(t.border).children(rows.map((r) => this.taskRow(r, t, wide)))));
        })));
  }

  searchView(t) {
    const wide = this.width >= 576;
    const rows = this.results ?? [];
    return v_flex().size_full().min_h(0)
      .child(h_flex().flex_none().gap(8).items_center().px(14).py(10).border_b_1().border_color(t.border)
        .child(svg(CHROME("search")).size(15).flex_none().text_color(t.muted))
        .child(div().flex_1().child(Input.new(this.find).h(30).text_size(15).text_color(t.foreground)))
        .child(this.status(t))
        .child(h_flex().flex_none().p(2).gap(2).rounded(7).bg(t.raised).children([["Active", false], ["All", true]].map(([label, all]) =>
          div().id(`scope-${label}`).px(8).py(2).rounded(5).text_size(12).cursor_pointer()
            .text_color(this.allStatuses === all ? t.foreground : t.muted)
            .when(this.allStatuses === all, (el) => el.bg(t.selected))
            .on_click((_e, cx) => {
              this.allStatuses = all;
              this.findTasks(this.find.value(), cx);
              cx.notify();
            })
            .child(label))))
        .child(this.iconButton("close-search", CHROME("x"), (cx) => this.stopSearch(cx), t)))
      .child(v_flex().id("results").flex_1().min_h(0).overflow_y_scrollbar().px(10).py(10).gap(2)
        .when(!this.results, (el) => el.child(div().px(6).text_size(12.5).text_color(t.dim).child("Type at least 2 characters · every task in the organization")))
        .when(Boolean(this.results) && !rows.length, (el) => el.child(div().px(6).text_size(12.5).text_color(t.dim).child("No tasks found")))
        .children(rows.map((r) => h_flex().id(`res-${r.id}`).gap(8).items_center().py(7).px(6).rounded(6).cursor_pointer()
          .hover((s) => s.bg(t.hover))
          .on_click((_e, cx) => this.open(r.id, cx))
          .child(this.dot(r.status, t))
          .when(wide && Boolean(r.number), (el) => el.child(div().w(40).flex_none().truncate().text_size(12).text_color(t.muted).child(r.number)))
          .child(v_flex().flex_1().min_w(0)
            .child(div().truncate().text_size(14).font_medium().text_color(r.closed ? t.muted : t.foreground).when(r.closed, (el) => el.line_through()).child(r.title))
            .child(div().truncate().text_size(12).text_color(t.muted).child(r.where))))));
  }

  field(label, value, t) {
    return v_flex().gap(3).min_w(0)
      .child(div().text_size(11.5).text_color(t.muted).child(label))
      .child(typeof value === "string" || value == null ? div().truncate().text_size(13).text_color(value ? t.foreground : t.dim).child(value ?? "—") : value);
  }

  valueText(value, t) {
    return typeof value === "string" || value == null ? div().truncate().text_size(13).text_color(value ? t.foreground : t.dim).child(value || "—") : value;
  }

  picked(label, display, which, picker, t, person = false) {
    return v_flex()
      .child(this.field(label, this.editable(`f-${which}`, this.valueText(display, t), this.picker === which, (cx) => this.togglePicker(which, cx, person), t), t))
      .when(this.picker === which, (el) => el.child(picker()));
  }

  typed(label, display, edit, t) {
    const open = this.editing?.kind === edit.kind && this.editing?.field?.id === edit.field?.id;
    const key = `e-${edit.kind}-${edit.field?.id ?? ""}`;
    return this.field(label, open ? this.lineEditor(edit, t) : this.editable(key, this.valueText(display, t), false, (cx) => this.startEdit(edit, cx), t), t);
  }

  customField(f, d, t) {
    const v = d.values[f.id];
    const option = (id) => f.options.find((o) => o.id === String(id))?.name;
    switch (f.type) {
      case 3: return this.picked(f.name, v != null ? option(v) : null, `field-${f.id}`, () => this.optionsPicker(f, d, t), t);
      case 5: return this.picked(f.name, [v ?? []].flat().map(option).filter(Boolean).join(", "), `field-${f.id}`, () => this.optionsPicker(f, d, t), t);
      case 6: return this.picked(f.name, v != null ? d.people[v] ?? `#${v}` : null, `field-${f.id}`, () => this.peoplePicker(v != null ? String(v) : null, (id, cx) => this.setField(f, id, cx), t), t, true);
      case 4: return this.typed(f.name, v ? day(v).label : null, { kind: "field", field: f }, t);
      default: return this.typed(f.name, v != null ? String(v) : null, { kind: "field", field: f }, t);
    }
  }

  rail(d, t, beside) {
    const status = h_flex().gap(6).items_center().child(this.dot(d.status, t)).child(div().truncate().text_size(13).child(d.status?.name ?? "No status"));
    const fields = [
      this.picked("Status", status, "status", () => this.statusPicker(d, t), t),
      this.picked("Assignee", h_flex().gap(8).items_center().min_w(0).child(this.avatar(d.assigneeAvatar, d.assignee, 20, t))
        .child(div().truncate().text_size(13).text_color(d.assignee ? t.foreground : t.dim).child(d.assignee ?? "Unassigned")), "assignee", () => this.peoplePicker(d.assigneeId, (id, cx) => this.setTask("assignee", "people", id, cx), t), t),
      this.picked("Task list", d.list, "list", () => this.listPicker(d, t), t),
      this.typed("Due date", this.due(d.due, d.closed, t), { kind: "due" }, t),
      this.typed("Start date", d.start && day(d.start).label, { kind: "start" }, t),
      this.typed("Estimate", minutes(d.estimate), { kind: "estimate" }, t),
      ...(d.worked ? [this.field("Tracked", minutes(d.worked), t)] : []),
      ...(d.fields ?? []).map((f) => this.customField(f, d, t)),
    ];
    return beside
      ? v_flex().id("rail").w(230).flex_none().min_h(0).overflow_y_scrollbar().gap(14).p(14).border_l_1().border_color(t.border).children(fields)
      : h_flex().flex_wrap().items_start().gap(14).py(12).children(fields.map((f) => div().w(170).child(f)));
  }

  subtasks(d, t) {
    return v_flex()
      .child(this.sectionHeader("Subtasks", d.subtaskRows.length, t))
      .children(d.subtaskRows.map((s) => h_flex().id(`sub-${s.id}`).gap(8).items_center().py(6).px(6).rounded(6).cursor_pointer()
        .hover((st) => st.bg(t.hover))
        .on_click((_e, cx) => this.open(s.id, cx))
        .child(this.dot(s.status, t))
        .child(div().flex_1().min_w(0).truncate().text_size(13.5).text_color(s.closed ? t.muted : t.foreground).when(s.closed, (el) => el.line_through()).child(s.title))
        .child(div().flex_none().text_size(12).text_color(t.muted).child(s.number ?? ""))));
  }

  todos(d, t) {
    const done = d.todoRows.filter((x) => x.closed).length;
    return v_flex()
      .child(this.sectionHeader("To-dos", d.todoRows.length ? `${done}/${d.todoRows.length}` : null, t))
      .children(d.todoRows.map((x) => h_flex().id(`todo-${x.id}`).gap(8).items_start().py(5).px(6).rounded(6).cursor_pointer()
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.toggleTodo(x, cx))
        .child(div().size(14).mt(2).flex_none().rounded(4).border_1().border_color(x.closed ? t.accent : t.input).when(x.closed, (el) => el.bg(t.accent))
          .flex().items_center().justify_center()
          .when(x.closed, (el) => el.child(svg(CHROME("check")).size(10).text_color(t.accent_foreground))))
        .child(div().flex_1().min_w(0).whitespace_normal().text_size(13.5).text_color(x.closed ? t.muted : t.foreground).when(x.closed, (el) => el.line_through()).child(x.description ?? ""))))
      .child(div().pt(4).child(this.textInput(this.todo, t)));
  }

  pill(s, t, struck) {
    if (!s) return div().text_size(12).text_color(t.dim).child("none");
    const color = s.color_id != null ? PALETTE[Number(s.color_id)] : null;
    return div().max_w(260).truncate().px(6).rounded(5).text_size(12).bg(color ? color + "2e" : t.raised).text_color(color ?? t.muted)
      .when(struck, (el) => el.line_through()).child(s.text);
  }

  change(c, t) {
    return h_flex().gap(6).items_center().flex_wrap()
      .child(div().text_size(12).text_color(t.muted).child(c.label))
      .when(Boolean(c.from), (el) => el.child(this.pill(c.from, t, true)).child(div().text_size(12).text_color(t.dim).child("→")))
      .child(this.pill(c.to, t, false));
  }

  feedRow(r, t) {
    const c = r.comment;
    const mine = c && r.authorId === this.person && this.editing?.id !== c.id;
    const same = r.items.every((x) => x.verb === r.items[0].verb);
    const headline = same ? `${r.items[0].verb}${r.items.length > 1 ? ` ×${r.items.length}` : ""}` : "made changes";
    return h_flex().gap(10).items_start()
      .child(this.avatar(r.avatar, r.author, 24, t))
      .child(v_flex().flex_1().min_w(0).gap(4)
        .child(h_flex().gap(6).items_center().flex_wrap()
          .child(div().text_size(12.5).font_semibold().child(r.author ?? "Someone"))
          .child(div().text_size(12.5).text_color(t.muted).child(headline))
          .child(div().text_size(11.5).text_color(t.dim).child(ago(r.at)))
          .when(Boolean(mine), (el) => el.child(div().id(`ce-${c.id}`).text_size(11.5).text_color(t.dim).cursor_pointer()
            .hover((s) => s.text_color(t.foreground)).on_click((_e, cx) => this.startEdit({ kind: "comment", id: c.id }, cx)).child("Edit"))))
        .when(Boolean(c), (el) => el.child(this.editing?.kind === "comment" && this.editing.id === c.id ? this.textEditor(t, (cx) => this.saveEdit(cx)) : this.html(`c-${c.id}`, c.body, t)))
        .children(r.items.filter((x) => x.subject).map((x) => div().truncate().text_size(12.5).text_color(t.foreground).child(same ? x.subject : `${x.verb}: ${x.subject}`)))
        .children(r.items.flatMap((x) => x.lines ?? []).map((line) => this.change(line, t))));
  }

  activity(d, t) {
    const filters = [["all", "All"], ["comments", "Comments"], ["changes", "Changes"]];
    const rows = (d.feed ?? []).filter((r) => this.feedFilter === "all" || (this.feedFilter === "comments") === Boolean(r.comment));
    return v_flex().gap(12)
      .child(h_flex().gap(8).items_center()
        .child(this.sectionHeader("Activity", d.feed?.length ?? 0, t))
        .child(div().flex_1())
        .child(h_flex().flex_none().p(2).gap(2).rounded(7).bg(t.raised).children(filters.map(([key, label]) =>
          div().id(`feed-${key}`).px(8).py(2).rounded(5).text_size(12).cursor_pointer()
            .text_color(this.feedFilter === key ? t.foreground : t.muted)
            .when(this.feedFilter === key, (el) => el.bg(t.selected))
            .on_click((_e, cx) => { this.feedFilter = key; cx.notify(); })
            .child(label)))))
      .child(v_flex().gap(6)
        .child(div().p(8).rounded(7).border_1().border_color(t.input).bg(t.surface).child(Textarea.new(this.comment).w_full().text_size(13).text_color(t.foreground)))
        .child(h_flex().justify_end().child(div().id("post").px(10).py(4).rounded(6).text_size(12.5).cursor_pointer().bg(t.solid).text_color(t.solid_foreground)
          .hover((s) => s.opacity(0.88)).on_click((_e, cx) => this.addComment(cx)).child("Comment"))))
      .when(!rows.length, (el) => el.child(div().text_size(12.5).text_color(t.dim).child(this.feedFilter === "changes" ? "Nothing has changed yet" : this.feedFilter === "comments" ? "No comments yet" : "Nothing has happened yet")))
      .children(rows.map((r) => this.feedRow(r, t)));
  }

  detailView(id, t) {
    const d = this.detail[id];
    const beside = this.width >= 760;
    const crumbs = d ? [d.project, d.folder, d.list].filter(Boolean).join("  ›  ") : "";
    const header = h_flex().flex_none().gap(8).items_center().px(10).py(8).border_b_1().border_color(t.border)
      .child(this.iconButton("back", CHROME("chevron-left"), (cx) => this.back(cx), t))
      .child(div().min_w(0).flex_1().truncate().text_size(12.5).text_color(t.muted).child(crumbs))
      .child(this.status(t))
      .when(Boolean(d?.number), (el) => el.child(div().flex_none().text_size(12.5).text_color(t.muted).child(`#${d.number}`)))
      .child(this.iconButton("web", ICON("external"), () => exec("open", [`${WEB}/tasks/${id}`]), t));
    if (!d) return v_flex().size_full().child(header).child(div().p(16).text_color(t.dim).child(this.error ?? "loading…"));
    const main = v_flex().id("main").flex_1().min_w(0).min_h(0).overflow_y_scrollbar().px(18).py(14).gap(16)
      .child(this.editing?.kind === "title"
        ? Input.new(this.line).h(40).px(8).rounded(7).border_1().border_color(t.accent).bg(t.surface).text_size(20).font_semibold().text_color(t.foreground)
        : div().id("title").whitespace_normal().px(4).rounded(6).cursor_pointer().hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.startEdit({ kind: "title" }, cx))
          .text_size(20).font_semibold().text_color(d.closed ? t.muted : t.foreground).when(d.closed, (el) => el.line_through()).child(d.title))
      .when(!beside, (el) => el.child(this.rail(d, t, false)))
      .child(this.editing?.kind === "description"
        ? this.textEditor(t, (cx) => this.saveEdit(cx))
        : v_flex().gap(4)
          .child(d.description ? this.html(`desc-${id}`, d.description, t) : div().text_size(13).text_color(t.dim).child("No description"))
          .child(div().id("edit-desc").text_size(11.5).text_color(t.dim).cursor_pointer().hover((s) => s.text_color(t.foreground))
            .on_click((_e, cx) => this.startEdit({ kind: "description" }, cx)).child(d.description ? "Edit description" : "Add description")))
      .when(d.subtaskRows.length > 0, (el) => el.child(this.separator(t)).child(this.subtasks(d, t)))
      .child(this.separator(t)).child(this.todos(d, t))
      .child(this.separator(t))
      .child(this.activity(d, t));
    return v_flex().size_full().min_h(0).child(header)
      .child(h_flex().flex_1().min_h(0).items_start().child(main).when(beside, (el) => el.child(this.rail(d, t, true))));
  }

  render() {
    const t = theme();
    const id = this.stack.at(-1);
    return v_flex().id("root").track_focus(this.handle).size_full().bg(t.background).text_color(t.foreground).text_size(13)
      .on_key_down((e, cx) => {
        if (e.keystroke === "cmd-enter" && this.editing) this.saveEdit(cx);
        else if (e.keystroke === "cmd-enter" && this.focusedState === this.comment) this.addComment(cx);
        else if ((e.key === "/" || e.key_char === "/") && !this.typing) {
          this.stack = [];
          this.picker = null;
          this.startSearch(cx);
        } else if (e.key !== "escape") return;
        else if (this.editing) this.cancelEdit(cx);
        else if (this.picker) this.picker = null;
        else if (this.searching && !id) this.stopSearch(cx);
        else if (this.typing) this.handle.focus();
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .on_size_change((size, cx) => { this.width = size.width; cx.notify(); })
      .child(id ? this.detailView(id, t) : this.searching ? this.searchView(t) : this.index(t));
  }
}
