import { exec, setShared } from "herdr";

const API = "https://api.productive.io/api/v2";
const ORG = "109";
const ENTITIES = { amp: "&", lt: "<", gt: ">", quot: '"', "#39": "'" };

let token = null;

async function headers() {
  if (!token) {
    const r = await exec("security", ["find-generic-password", "-a", "productive", "-s", "PRODUCTIVE_AUTH_TOKEN", "-w"]);
    if (r.code !== 0) throw new Error("PRODUCTIVE_AUTH_TOKEN is not in the keychain (run /secrets)");
    token = r.stdout.trim();
  }
  return { "X-Auth-Token": token, "X-Organization-Id": ORG, "Content-Type": "application/vnd.api+json" };
}

const plain = (html) => (html ?? "").replace(/<[^>]+>/g, "").replace(/&(amp|lt|gt|quot|#39);/g, (_m, e) => ENTITIES[e]);

export async function loadInbox() {
  const r = await fetch(`${API}/notifications?filter%5Bdismissed%5D=false&page%5Bsize%5D=100&include=actor`, { headers: await headers() });
  if (!r.ok) throw new Error(`${r.status} on /notifications`);
  const body = await r.json();
  const people = new Map((body.included ?? []).map((x) => [`${x.type}:${x.id}`, [x.attributes.first_name, x.attributes.last_name].filter(Boolean).join(" ")]));
  const items = body.data.map((n) => {
    const a = n.attributes, actor = n.relationships.actor?.data;
    const bold = [...(a.title ?? "").matchAll(/<b>([\s\S]*?)<\/b>/g)].map((m) => plain(m[1]));
    return {
      id: n.id,
      action: plain((a.title ?? "").split("<b>")[0]).trim(),
      item: bold[0] ?? null,
      project: bold[1] ?? null,
      excerpt: plain(a.excerpt),
      read: a.read,
      at: a.last_action_at,
      actor: actor ? people.get(`${actor.type}:${actor.id}`) ?? null : null,
      task: a.target_type === "task" ? a.target_id : a.parent_type === "task" ? a.parent_id : null,
    };
  });
  setShared("productive.inbox", items);
}
