import { exec, hc, run } from "herdr";
import { target, forBrowser, forPreview, driveUrl } from "./target.js";

const BROWSER = "app.zen-browser.zen";

async function hostOf(machine) {
  const r = await hc(["machine", "ls", "--json"]);
  return JSON.parse(r.stdout).machines.find((m) => m.name === machine)?.host ?? null;
}

export async function handleLink(click) {
  const at = target(click);
  if (!at) return "pass";
  const { source } = click;

  if (forBrowser(at.path)) {
    const url = source.machine ? driveUrl(await hostOf(source.machine), at.path) : at.path;
    if (!url) return "pass";
    await exec("open", ["-b", BROWSER, url]);
    return "handled";
  }

  if (forPreview(at.path)) {
    let file = at.path;
    if (source.machine) {
      const url = driveUrl(await hostOf(source.machine), at.path);
      if (!url) return "pass";
      file = `/tmp/glados-links/${Date.now()}-${at.path.split("/").pop()}`;
      if ((await exec("curl", ["-sf", "--create-dirs", "-o", file, url])).code !== 0) return "pass";
    }
    await exec("open", ["-a", "Preview", file]);
    return "handled";
  }

  run("tab.new", {
    space: source.space ?? undefined,
    name: at.path.split("/").pop(),
    folder: source.cwd ?? undefined,
    argv: ["/bin/zsh", "-lc", 'exec nvim "+call cursor($1, $2)" "$0"', at.path, at.line, at.col],
  });
  return "handled";
}
