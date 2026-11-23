// node activity.test.mjs
import assert from "node:assert/strict";
import { describe, feed } from "./activity.js";

const TASK = "16842041";
const act = (id, at, attributes, creatorId = "1", comment = null) =>
  ({ id, at, creatorId, author: `P${creatorId}`, comment, raw: { attributes: { item_id: TASK, parent_id: TASK, created_at: at, ...attributes } } });

const status = describe({ attributes: { item_type: "task", item_id: TASK, event: "update", changeset: [{ workflow_status_id: [{ value: "Peer Review", id: 48473, color_id: 6 }, { value: "On Latest", id: 50357, color_id: 12 }] }] } }, TASK);
assert.deepEqual(status.lines, [{ label: "Status", from: { text: "Peer Review", color_id: 6 }, to: { text: "On Latest", color_id: 12 } }]);

const estimate = describe({ attributes: { item_type: "task", item_id: TASK, event: "update", changeset: [{ initial_estimate: [null, { value: 90 }] }, { due_date: [{ value: "2026-11-20" }, null] }] } }, TASK);
assert.deepEqual(estimate.lines.map((l) => [l.label, l.from?.text ?? null, l.to?.text ?? null]), [["Estimate", null, "1h 30m"], ["Due date", "20 Nov 2026", null]]);

const field = describe({ attributes: { item_type: "task", item_id: TASK, event: "update", changeset: [{ "custom_field:24090:person:PM": [null, { value: "Ivor Bokun", id: 1163314 }] }] } }, TASK);
assert.equal(field.lines[0].label, "PM");

assert.equal(describe({ attributes: { item_type: "todo", event: "update", item_name: "Design review", changeset: [{ closed_at: [null, { value: "2026-11-03T11:53:30" }] }] } }, TASK).verb, "completed a to-do");
assert.equal(describe({ attributes: { item_type: "task", item_id: "999", item_name: "Sub", event: "create", changeset: [] } }, TASK).verb, "created a subtask");
assert.equal(describe({ attributes: { item_type: "task", item_id: TASK, event: "update", changeset: [{ tags: [null, { value: [] }] }] } }, TASK), null);
assert.equal(describe({ attributes: { item_type: "comment", event: "update", changeset: [] } }, TASK), null);

const todo = (id, sec) => act(id, `2026-11-03T11:53:${sec}.000+01:00`, { item_type: "todo", item_id: id, event: "update", item_name: `todo ${id}`, changeset: [{ closed_at: [null, { value: "x" }] }] });
const rows = feed([
  todo("t1", 10), todo("t2", 20), todo("t3", 30),
  act("c1", "2026-11-04T10:00:00.000+01:00", { item_type: "comment", item_id: "c1", event: "create" }, "1", { id: "c1", body: "<p>a</p>" }),
  act("c2", "2026-11-04T10:00:05.000+01:00", { item_type: "comment", item_id: "c2", event: "create" }, "1", { id: "c2", body: "<p>b</p>" }),
  act("o1", "2026-11-03T11:53:35.000+01:00", { item_type: "todo", item_id: "o1", event: "create", item_name: "other person" }, "2"),
], TASK);
assert.deepEqual(rows.map((r) => r.id), ["c2", "c1", "o1", "t3"], "newest first; two comments stay apart; another person's row splits");
assert.equal(rows.at(-1).items.length, 3, "three to-dos closed within 30s by one person are one row");
console.log("ok · activity feed");
