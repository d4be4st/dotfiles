const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const GROUP_MS = 30000;
const SKIP = new Set(["tags", "attachments", "type_id", "description", "remaining_time", "placeholder_usages", "position"]);
const LABELS = {
  workflow_status_id: "Status", assignee: "Assignee", title: "Title", due_date: "Due date", start_date: "Start date",
  initial_estimate: "Estimate", task_list: "Task list", project: "Project", parent_task_id: "Parent task", closed_at: "Closed",
};

const date = (v) => {
  const m = String(v).match(/^(\d{4})-(\d{2})-(\d{2})$/);
  return m ? `${+m[3]} ${MONTHS[+m[2] - 1]} ${m[1]}` : String(v);
};
const duration = (n) => [Math.floor(n / 60) && `${Math.floor(n / 60)}h`, n % 60 && `${n % 60}m`].filter(Boolean).join(" ") || "0m";

function side(field, s) {
  if (s == null || s.value == null || s.value === "" || (Array.isArray(s.value) && !s.value.length)) return null;
  const v = s.value;
  const text = Array.isArray(v) ? v.map((x) => x?.value ?? x).join(", ")
    : field === "initial_estimate" ? duration(v)
      : /date$/.test(field) || /:date:/.test(field) ? date(v)
        : String(v);
  return { text, color_id: s.color_id ?? null };
}

function changes(changeset) {
  return (changeset ?? []).flatMap((entry) => Object.entries(entry))
    .filter(([field]) => !SKIP.has(field))
    .map(([field, [from, to]]) => ({
      label: LABELS[field] ?? (field.startsWith("custom_field:") ? field.split(":").slice(3).join(":") : field.replace(/_/g, " ")),
      from: side(field, from),
      to: side(field, to),
    }))
    .filter((c) => c.from?.text !== c.to?.text);
}

export function describe(a, taskId) {
  const at = a.attributes ?? a;
  const subject = String(at.item_id ?? "") === String(taskId) ? null : at.item_name;
  const set = at.changeset ?? [];
  const closed = set.find((c) => c.closed_at)?.closed_at;
  switch (at.item_type) {
    case "comment": return at.event === "create" ? { verb: "commented" } : null;
    case "todo":
      if (at.event === "create") return { verb: "added a to-do", subject: at.item_name };
      if (at.event === "destroy") return { verb: "deleted a to-do", subject: at.item_name };
      if (closed) return { verb: closed[1]?.value ? "completed a to-do" : "reopened a to-do", subject: at.item_name };
      return { verb: "updated a to-do", subject: at.item_name, lines: changes(set).filter((c) => c.label !== "description") };
    case "attachment": return { verb: at.event === "destroy" ? "removed an attachment" : "added an attachment", subject: at.item_name };
    case "task":
      if (at.event === "create") return subject ? { verb: "created a subtask", subject } : { verb: "created the task" };
      if (at.event === "destroy") return { verb: "deleted a subtask", subject };
      {
        const lines = changes(set);
        const description = set.some((c) => c.description);
        if (!lines.length && !description) return null;
        return { verb: subject ? "updated a subtask" : description && !lines.length ? "updated the description" : "made changes", subject, lines, description };
      }
    default: return { verb: `${at.event === "create" ? "added" : "updated"} ${String(at.item_type).replace(/_/g, " ")}`, subject: at.item_name };
  }
}

const groupKey = (at, taskId) => `${at.creator}-${at.item_type === "todo" ? `todo-${at.parent_id}` : `${at.item_type}-${at.item_id}`}`;

export function feed(activities, taskId) {
  const rows = [];
  const sorted = [...activities].sort((x, y) => Date.parse(y.at) - Date.parse(x.at));
  for (const a of sorted) {
    const what = describe(a.raw, taskId);
    if (!what) continue;
    const last = rows.at(-1);
    const key = groupKey({ ...a.raw.attributes, creator: a.creatorId }, taskId);
    if (last && last.key === key && !(what.verb === "commented" && last.comment) && Math.abs(Date.parse(last.oldest) - Date.parse(a.at)) <= GROUP_MS) {
      last.items.push(what);
      last.oldest = a.at;
      if (what.verb === "commented") last.comment = a.comment;
      continue;
    }
    rows.push({ id: a.id, key, at: a.at, oldest: a.at, author: a.author, authorId: a.creatorId, avatar: a.avatar, items: [what], comment: what.verb === "commented" ? a.comment : null });
  }
  return rows.map(({ key, oldest, ...row }) => row);
}
