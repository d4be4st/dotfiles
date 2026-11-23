// Productive stores descriptions and comments as HTML; the dialog edits them as markdown.

const ENTITIES = { amp: "&", lt: "<", gt: ">", quot: '"', "#39": "'", apos: "'", nbsp: " " };
const decode = (s) => s.replace(/&(#\d+|#x[0-9a-f]+|\w+);/gi, (m, e) =>
  ENTITIES[e.toLowerCase()] ?? (e[0] === "#" ? String.fromCodePoint(e[1] === "x" ? parseInt(e.slice(2), 16) : +e.slice(1)) : m));
const escape = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const VOID = new Set(["br", "hr", "img", "input"]);
const KNOWN = new Set(["p", "div", "br", "strong", "b", "em", "i", "s", "del", "code", "pre", "a", "ul", "ol", "li", "blockquote",
  "h1", "h2", "h3", "h4", "table", "thead", "tbody", "tr", "th", "td", "span"]);

function parse(html) {
  const root = { tag: "root", children: [] };
  const stack = [root];
  for (const m of html.matchAll(/<(\/?)([a-z0-9-]+)((?:\s[^>]*?)?)(\/?)>|([^<]+)|(<)/gi)) {
    const top = stack.at(-1);
    if (m[5] !== undefined || m[6]) { top.children.push({ text: decode(m[5] ?? "<") }); continue; }
    const tag = m[2].toLowerCase();
    if (m[1]) {
      const at = stack.findLastIndex((n) => n.tag === tag);
      if (at > 0) stack.length = at;
      continue;
    }
    const node = { tag, attrs: m[3] ?? "", raw: m[0], children: [] };
    top.children.push(node);
    if (!VOID.has(tag) && !m[4]) stack.push(node);
  }
  return root;
}

const attr = (n, name) => decode(n.attrs.match(new RegExp(`${name}="([^"]*)"`, "i"))?.[1] ?? "");
const MENTION = /@\[\{.*?\}\]/g;
const escapeMd = (s) => s.split(/(@\[\{.*?\}\])/).map((part, i) => (i % 2 ? part : part.replace(/([*`\\[\]])/g, "\\$1"))).join("");

const MARKS = new Set(["strong", "b", "em", "i", "s", "del"]);
const merged = (nodes) => nodes.reduce((out, n) => {
  const last = out.at(-1);
  if (MARKS.has(n.tag) && last?.tag === n.tag) out[out.length - 1] = { ...last, children: [...last.children, ...n.children] };
  else out.push(n);
  return out;
}, []);

function inline(nodes) {
  return merged(nodes).map((n) => {
    if (n.text !== undefined) return escapeMd(n.text);
    const inner = () => inline(n.children);
    switch (n.tag) {
      case "strong": case "b": return `**${inner()}**`;
      case "em": case "i": return `*${inner()}*`;
      case "s": case "del": return `~~${inner()}~~`;
      case "code": { const t = text(n); const fence = t.includes("`") ? "``" : "`"; return `${fence}${t}${fence}`; }
      case "a": { const href = attr(n, "href"); const label = inner(); return label === escapeMd(href) ? href : `[${label}](${href})`; }
      case "br": return "\n";
      case "span": case "p": case "div": return inner();
      default: return KNOWN.has(n.tag) ? inner() : `${n.raw}${inner()}${VOID.has(n.tag) ? "" : `</${n.tag}>`}`;
    }
  }).join("");
}

const text = (n) => (n.text !== undefined ? n.text : n.children.map(text).join(""));
const indent = (s, pad) => s.split("\n").map((l) => (l ? pad + l : l)).join("\n");

function blocks(nodes) {
  const out = [];
  let run = [];
  const flush = () => { const t = inline(run).trim(); if (t) out.push(t); run = []; };
  for (const n of nodes) {
    if (n.text !== undefined || !isBlock(n)) { run.push(n); continue; }
    flush();
    out.push(block(n));
  }
  flush();
  return out.filter(Boolean).join("\n\n");
}

const BLOCKS = new Set(["p", "div", "pre", "ul", "ol", "blockquote", "h1", "h2", "h3", "h4", "table"]);
const isBlock = (n) => BLOCKS.has(n.tag) || (!KNOWN.has(n.tag) && n.tag !== "u" && n.tag !== "mark");

function block(n) {
  switch (n.tag) {
    case "p": return inline(n.children).trim();
    case "div": return blocks(n.children);
    case "h1": case "h2": case "h3": case "h4": return `${"#".repeat(+n.tag[1])} ${inline(n.children).trim()}`;
    case "pre": {
      const code = n.children.find((c) => c.tag === "code");
      const lang = code ? attr(code, "class").match(/language-(\S+)/)?.[1] ?? "" : "";
      return `\`\`\`${lang}\n${text(code ?? n).replace(/\n$/, "")}\n\`\`\``;
    }
    case "blockquote": return blocks(n.children).split("\n").map((l) => (l ? `> ${l}` : ">")).join("\n");
    case "ul": case "ol": return list(n);
    case "table": return table(n);
    default: return `${n.raw}${inline(n.children)}</${n.tag}>`;
  }
}

function list(n) {
  return n.children.filter((c) => c.tag === "li").map((li, i) => {
    const marker = n.tag === "ol" ? `${i + 1}. ` : "- ";
    const body = blocks(li.children);
    const [first, ...rest] = body.split("\n");
    return marker + first + (rest.length ? `\n${indent(rest.join("\n"), " ".repeat(marker.length))}` : "");
  }).join("\n");
}

function table(n) {
  const rows = [];
  const walk = (x) => (x.tag === "tr" ? rows.push(x) : (x.children ?? []).forEach(walk));
  walk(n);
  const cells = rows.map((r) => r.children.filter((c) => c.tag === "td" || c.tag === "th").map((c) => blocks(c.children).replace(/\n+/g, " ").replace(/\|/g, "\\|")));
  if (!cells.length) return "";
  const width = Math.max(...cells.map((r) => r.length));
  const line = (r) => `| ${Array.from({ length: width }, (_, i) => r[i] ?? "").join(" | ")} |`;
  return [line(cells[0]), `| ${Array(width).fill("---").join(" | ")} |`, ...cells.slice(1).map(line)].join("\n");
}

export function htmlToMarkdown(html) {
  return html ? blocks(parse(html).children).replace(/\n{3,}/g, "\n\n").trim() : "";
}

function md(s) {
  const codes = [];
  const keep = (html) => `\u0000${codes.push(html) - 1}\u0000`;
  return s
    .replace(MENTION, (m) => keep(escape(m)))
    .replace(/(`+)([\s\S]*?[^`])\1(?!`)/g, (_, _f, c) => keep(`<code>${escape(c)}</code>`))
    .replace(/\\([*`\\[\]|])/g, (_, c) => keep(escape(c)))
    .replace(/<\/?[a-z][a-z0-9-]*(?:\s[^<>]*)?\/?>/gi, (tag) => keep(tag))
    .replace(/[&<>]/g, escape)
    .replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (_, label, href) => keep(`<a href="${href}">${label}</a>`))
    .replace(/https?:\/\/[^\s<>()*~`]+[^\s<>().,;:!?'"*~`]/g, (url) => keep(`<a href="${url}">${url}</a>`))
    .replace(/\*\*([^*]+?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*([^*\s][^*]*?)\*/g, "<em>$1</em>")
    .replace(/~~([^~]+?)~~/g, "<s>$1</s>")
    .replace(/\n/g, "<br>")
    .replace(/\u0000(\d+)\u0000/g, (_, i) => codes[i])
    .replace(/\u0000(\d+)\u0000/g, (_, i) => codes[i]);
}

const LIST = /^(\s*)([-*+]|\d+[.)])\s+(.*)$/;

function listHtml(lines) {
  const ordered = /\d/.test(lines[0].match(LIST)[2]);
  const items = [];
  for (const l of lines) {
    const m = l.match(LIST);
    if (m && m[1].length === lines[0].match(LIST)[1].length) items.push([m[3]]);
    else items.at(-1).push(l.replace(/^\s{1,4}/, ""));
  }
  const tag = ordered ? "ol" : "ul";
  return `<${tag}>${items.map(([first, ...rest]) => {
    const nested = rest.length ? markdownToHtml(rest.join("\n")) : "";
    return `<li><p>${md(first)}</p>${nested}</li>`;
  }).join("")}</${tag}>`;
}

const cellsOf = (l) => l.trim().replace(/^\||\|$/g, "").split(/(?<!\\)\|/).map((c) => md(c.trim().replace(/\\\|/g, "|")));

export function markdownToHtml(src) {
  const lines = (src ?? "").replace(/\r\n?/g, "\n").split("\n");
  const out = [];
  for (let i = 0; i < lines.length;) {
    const l = lines[i];
    if (!l.trim()) { i++; continue; }
    const fence = l.match(/^```\s*(\S*)/);
    if (fence) {
      const body = [];
      for (i++; i < lines.length && !/^```/.test(lines[i]); i++) body.push(lines[i]);
      i++;
      out.push(`<pre><code${fence[1] ? ` class="language-${fence[1]}"` : ""}>${escape(body.join("\n"))}</code></pre>`);
      continue;
    }
    const heading = l.match(/^(#{1,4})\s+(.*)$/);
    if (heading) { out.push(`<h${heading[1].length}>${md(heading[2])}</h${heading[1].length}>`); i++; continue; }
    if (/^>/.test(l)) {
      const body = [];
      for (; i < lines.length && /^>/.test(lines[i]); i++) body.push(lines[i].replace(/^>\s?/, ""));
      out.push(`<blockquote>${markdownToHtml(body.join("\n"))}</blockquote>`);
      continue;
    }
    if (/^\|/.test(l) && /^\|?\s*:?-{3,}/.test(lines[i + 1] ?? "")) {
      const rows = [cellsOf(l)];
      for (i += 2; i < lines.length && /^\|/.test(lines[i]); i++) rows.push(cellsOf(lines[i]));
      out.push(`<table><tbody>${rows.map((r, n) => `<tr>${r.map((c) => (n ? `<td><p>${c}</p></td>` : `<th><p>${c}</p></th>`)).join("")}</tr>`).join("")}</tbody></table>`);
      continue;
    }
    if (LIST.test(l)) {
      const body = [];
      for (; i < lines.length && (LIST.test(lines[i]) || /^\s+\S/.test(lines[i]) || (!lines[i].trim() && /^\s+\S|^\s*([-*+]|\d+[.)])\s/.test(lines[i + 1] ?? ""))); i++)
        if (lines[i].trim()) body.push(lines[i]);
      out.push(listHtml(body));
      continue;
    }
    const para = [];
    for (; i < lines.length && lines[i].trim() && !/^(```|#{1,4}\s|>|\|)/.test(lines[i]) && !LIST.test(lines[i]); i++) para.push(lines[i]);
    out.push(`<p>${md(para.join("\n"))}</p>`);
  }
  return out.join("");
}
