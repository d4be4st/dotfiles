const POSITION = /^(.*?)(?::(\d+))?(?::(\d+))?$/;
const DRIVE = "http://100.100.100.100:8080/d4be4st.github";
const SHARE = { name: "stef", root: "/Users/stef/" };

const decode = (text) => {
  try { return decodeURIComponent(text); } catch { return text; }
};

export function target({ link, source }) {
  const raw = link.kind === "url" ? link.url.replace(/^nvim:\/\/file/i, "") : link.raw.replace(/^file:\/\/[^/]*/i, "");
  const [, named, line = "1", col = "1"] = decode(raw).match(POSITION);
  let path = link.kind === "file" && link.path ? link.path.match(POSITION)[1] : named;
  if (!path.startsWith("/")) {
    if (!source.cwd || path.startsWith("~")) return null;
    path = `${source.cwd}/${path}`;
  }
  return { path, line, col };
}

export const forBrowser = (path) => /\.(html?|md)$/i.test(path);
export const forPreview = (path) => /\.(png|jpe?g|gif|webp|heic|tiff?|bmp)$/i.test(path);

export function driveUrl(host, path) {
  if (!path.startsWith(SHARE.root)) return null;
  const rest = path.slice(SHARE.root.length).split("/").map(encodeURIComponent).join("/");
  return `${DRIVE}/${host}/${SHARE.name}/${rest}`;
}
