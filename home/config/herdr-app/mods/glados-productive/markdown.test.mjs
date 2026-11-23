// node markdown.test.mjs
import assert from "node:assert/strict";
import { htmlToMarkdown, markdownToHtml } from "./markdown.js";

const cases = {
  paragraphs: "<p>One <strong>bold</strong> and <em>soft</em> and <code>a_b</code>.</p><p>Two<br>lines</p>",
  link: '<p>See <a href="https://x.io/a?b=1&amp;c=2">the docs</a> or https://y.io/z</p>',
  boldUrl: "<p><strong>Research: https://devportal.productive.io/s/abc</strong></p>",
  mention: '<p>@[{"type":"person","id":"383705","label":"Stjepan Hadjić","avatar_url":"https://files.productive.io/a.jpg","is_done":false}] ovo je stabilno</p>',
  adjacentMarks: "<p><strong>Deals — a new </strong><strong><code>deal_members</code></strong><strong> group.</strong></p>",
  lists: "<ol><li><p><strong>api</strong> — first</p><ul><li><p>nested</p></li></ul></li><li><p>second</p></li></ol>",
  code: '<pre><code class="language-js">if (a &lt; b) {\n  return `x`;\n}</code></pre>',
  table: "<table><tbody><tr><th><p>pattern</p></th><th><p>count</p></th></tr><tr><td><p><code>sembly</code></p></td><td><p>42</p></td></tr></tbody></table>",
  quote: "<blockquote><p>quoted <em>text</em></p></blockquote>",
  rawTag: "<p>keep <u>underline</u> as html</p>",
};

for (const [name, html] of Object.entries(cases)) {
  const md = htmlToMarkdown(html);
  assert.equal(htmlToMarkdown(markdownToHtml(md)), md, `${name}: markdown is not stable`);
  const text = (h) => h.replace(/<[^>]+>/g, "").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/\s+/g, "");
  assert.equal(text(markdownToHtml(md)), text(html), `${name}: text changed`);
}

assert.match(htmlToMarkdown(cases.mention), /^@\[\{"type":"person"/, "mention JSON stays verbatim");
assert.equal(htmlToMarkdown(cases.adjacentMarks), "**Deals — a new `deal_members` group.**");
assert.equal(markdownToHtml("- a\n  - b\n- c"), "<ul><li><p>a</p><ul><li><p>b</p></li></ul></li><li><p>c</p></li></ul>");
assert.equal(markdownToHtml("snake_case stays"), "<p>snake_case stays</p>");
console.log(`ok · ${Object.keys(cases).length} round trips`);
