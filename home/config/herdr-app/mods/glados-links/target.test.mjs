// node target.test.mjs
import assert from "node:assert/strict";
import { target, forBrowser, forPreview, driveUrl } from "./target.js";

const source = { cwd: "/Users/stef/ws/api", machine: "server" };

assert.deepEqual(
  target({ link: { kind: "url", raw: "", url: "nvim://file/Users/stef/ws/api/app/a%20b.rb:42:7" }, source }),
  { path: "/Users/stef/ws/api/app/a b.rb", line: "42", col: "7" },
);
assert.deepEqual(
  target({ link: { kind: "file", raw: "app/foo.rb:12", path: null }, source }),
  { path: "/Users/stef/ws/api/app/foo.rb", line: "12", col: "1" },
);
assert.deepEqual(
  target({ link: { kind: "file", raw: "file://bestija-v4/Users/stef/out/r.html", path: null }, source }),
  { path: "/Users/stef/out/r.html", line: "1", col: "1" },
);
assert.equal(target({ link: { kind: "file", raw: "x.rb", path: null }, source: { cwd: null } }), null);

assert.ok(forBrowser("/a/README.md") && forBrowser("/a/r.HTML") && !forBrowser("/a/r.rb"));
assert.ok(forPreview("/a/shot.PNG") && forPreview("/a/p.jpeg") && !forPreview("/a/r.rb") && !forPreview("/a/r.md"));
assert.equal(
  driveUrl("bestija-v4", "/Users/stef/out/a #1.html"),
  "http://100.100.100.100:8080/d4be4st.github/bestija-v4/stef/out/a%20%231.html",
);
assert.equal(driveUrl("bestija-v4", "/tmp/x.html"), null);
console.log("ok");
