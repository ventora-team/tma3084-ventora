import { assertEquals } from "jsr:@std/assert@1";
import { extractText, handler } from "./index.ts";

Deno.env.set("SUPABASE_URL", "http://db");
Deno.env.set("SUPABASE_ANON_KEY", "anon");

// Fake network: is_staff answers `staff`, Gemini answers `gemini`.
function fakeFetch(staff: Response, gemini?: Response) {
  const real = globalThis.fetch;
  globalThis.fetch = ((url: string) =>
    Promise.resolve(String(url).includes("is_staff") ? staff : gemini!)) as typeof fetch;
  return () => (globalThis.fetch = real);
}
const staffReq = (body = "{}") =>
  new Request("http://x", { method: "POST", body, headers: { Authorization: "Bearer user-token" } });

Deno.test("extractText joins parts and copes with empty answers", () => {
  assertEquals(extractText({ candidates: [{ content: { parts: [{ text: "Hi " }, { text: "there" }] } }] }), "Hi there");
  assertEquals(extractText({}), "");
});

Deno.test("no login token is refused", async () => {
  const res = await handler(new Request("http://x", { method: "POST", body: "{}" }));
  assertEquals(res.status, 401);
});

Deno.test("anon key or inactive account is refused", async () => {
  const restore = fakeFetch(new Response('{"message":"permission denied"}', { status: 401 }));
  try {
    assertEquals((await handler(staffReq())).status, 401);
  } finally { restore(); }
  const restore2 = fakeFetch(new Response("false"));
  try {
    assertEquals((await handler(staffReq())).status, 401);
  } finally { restore2(); }
});

Deno.test("missing key gives a clear error, not a crash", async () => {
  Deno.env.delete("GEMINI_API_KEY");
  const restore = fakeFetch(new Response("true"));
  try {
    assertEquals((await handler(staffReq())).status, 500);
  } finally { restore(); }
});

Deno.test("Gemini failure becomes a template fallback message", async () => {
  Deno.env.set("GEMINI_API_KEY", "test");
  const restore = fakeFetch(new Response("true"), new Response("quota", { status: 429 }));
  try {
    const res = await handler(staffReq('{"question":"hi"}'));
    assertEquals(res.status, 502);
    assertEquals((await res.json()).status, 429);
  } finally { restore(); }
});

Deno.test("staff gets a draft", async () => {
  Deno.env.set("GEMINI_API_KEY", "test");
  const restore = fakeFetch(
    new Response("true"),
    new Response(JSON.stringify({ candidates: [{ content: { parts: [{ text: "Yes, we do!" }] } }] })),
  );
  try {
    assertEquals((await (await handler(staffReq('{"question":"Chocolate?"}'))).json()).draft, "Yes, we do!");
  } finally { restore(); }
});

Deno.test("Gemini hang or network error becomes the template fallback", async () => {
  Deno.env.set("GEMINI_API_KEY", "test");
  const real = globalThis.fetch;
  globalThis.fetch = ((url: string) =>
    String(url).includes("is_staff") ? Promise.resolve(new Response("true")) : Promise.reject(new DOMException("timed out", "TimeoutError"))) as typeof fetch;
  try {
    const res = await handler(staffReq());
    assertEquals(res.status, 502);
  } finally { globalThis.fetch = real; }
});

Deno.test("only POST is allowed", async () => {
  assertEquals((await handler(new Request("http://x"))).status, 405);
});

Deno.test("empty Gemini answer becomes the template fallback", async () => {
  Deno.env.set("GEMINI_API_KEY", "test");
  const restore = fakeFetch(new Response("true"), new Response(JSON.stringify({ candidates: [] })));
  try {
    assertEquals((await handler(staffReq())).status, 502);
  } finally { restore(); }
});
