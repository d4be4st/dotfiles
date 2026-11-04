import net from "net";
import { exec, setShared } from "herdr";

export const HOST = "bestija-v4";
export const PORT = 4281;
export const BASE = `http://${HOST}:${PORT}`;

const utf8 = (bytes) => decodeURIComponent(Array.from(bytes, (b) => `%${b.toString(16).padStart(2, "0")}`).join(""));

const join = (a, b) => {
  const out = new Uint8Array(a.length + b.length);
  out.set(a);
  out.set(b, a.length);
  return out;
};

const eventEnd = (bytes) => {
  for (let i = 0; i + 1 < bytes.length; i++) if (bytes[i] === 10 && bytes[i + 1] === 10) return i;
  return -1;
};

export async function follow(view, cx) {
  for (;;) {
    try {
      const socket = await net.connect(HOST, PORT);
      view.socket = socket;
      await socket.write(`GET /feed HTTP/1.0\r\nHost: ${HOST}:${PORT}\r\nAccept: text/event-stream\r\n\r\n`);
      let pending = new Uint8Array(0);
      for (;;) {
        const chunk = await socket.read();
        if (chunk === null) break;
        pending = join(pending, chunk);
        for (let end = eventEnd(pending); end >= 0; end = eventEnd(pending)) {
          const data = utf8(pending.subarray(0, end)).split("\n").find((l) => l.startsWith("data: "));
          pending = pending.slice(end + 2);
          if (!data) continue;
          setShared("factory.feed", JSON.parse(data.slice(6)));
          view.error = null;
          cx.notify();
        }
      }
    } catch {
      view.error = `can't reach ${BASE}`;
      cx.notify();
    }
    await exec("sleep", ["1"]).catch(() => {});
  }
}
