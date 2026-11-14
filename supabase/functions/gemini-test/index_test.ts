import { assertEquals } from "jsr:@std/assert@1";
import { extractText, handler } from "./index.ts";

Deno.test("extractText joins parts and copes with empty answers", () => {
  assertEquals(extractText({ candidates: [{ content: { parts: [{ text: "Hi " }, { text: "there" }] } }] }), "Hi there");
  assertEquals(extractText({}), "");
});

Deno.test("missing key gives a clear error, not a crash", async () => {
  Deno.env.delete("GEMINI_API_KEY");
  const res = await handler(new Request("http://x", { method: "POST", body: "{}" }));
  assertEquals(res.status, 500);
});

Deno.test("Gemini failure becomes a template fallback message", async () => {
  Deno.env.set("GEMINI_API_KEY", "test");
  const realFetch = globalThis.fetch;
  globalThis.fetch = () => Promise.resolve(new Response("quota", { status: 429 }));
  try {
    const res = await handler(new Request("http://x", { method: "POST", body: '{"question":"hi"}' }));
    assertEquals(res.status, 502);
    assertEquals((await res.json()).status, 429);
  } finally {
    globalThis.fetch = realFetch;
  }
});
