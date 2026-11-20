// One test call to Google Gemini. The key lives only in Supabase secrets:
//   supabase secrets set GEMINI_API_KEY=...
// Supabase's verify_jwt also lets the public anon key through, so the function itself
// checks that the caller is an active staff member before using the AI quota.

// Pinned, not "-latest": on 17 Nov "gemini-flash-latest" moved to a slower model that hung for
// free-tier keys (503 after 20+ s), while the lite models answered in about 1.5 s.
const GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent";

export function extractText(body: unknown): string {
  // deno-lint-ignore no-explicit-any
  const parts = (body as any)?.candidates?.[0]?.content?.parts ?? [];
  return parts.map((p: { text?: string }) => p.text ?? "").join("").trim();
}

// Calls a database function with the caller's own token and answers true only if it returns true.
// The anon key gets "permission denied", so it fails here too.
async function dbSaysTrue(req: Request, fn: string): Promise<boolean> {
  const auth = req.headers.get("Authorization");
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  if (!auth || !url || !anon) return false;
  const res = await fetch(`${url}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: { Authorization: auth, apikey: anon, "Content-Type": "application/json" },
    body: "{}",
    signal: AbortSignal.timeout(5_000),
  });
  const ok = res.ok && (await res.json()) === true;
  console.log(fn, res.status, ok);
  return ok;
}

// True only for active staff.
export const isActiveStaff = (req: Request) => dbSaysTrue(req, "is_staff");

// Counts this request against the shop's daily cap (100, set in the database); false once it is used up.
export const useAiQuota = (req: Request) => dbSaysTrue(req, "use_ai_quota");

// The Flutter web build runs in a browser, which asks first with OPTIONS and needs these headers.
// Safe to allow any site: every POST still needs an active staff member's own login token.
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

export async function handler(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Use POST" }, 405);
  try {
    if (!(await isActiveStaff(req))) return json({ error: "Staff login required" }, 401);
  } catch (e) {
    console.error("staff check failed", e);
    return json({ error: "Could not check login, try again" }, 503);
  }
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return json({ error: "GEMINI_API_KEY is not set" }, 500);

  // If the count cannot be checked, play safe and send staff to the templates.
  const underCap = await useAiQuota(req).catch((e) => {
    console.error("quota check failed", e);
    return false;
  });
  if (!underCap) return json({ error: "AI is unavailable, use a template reply", reason: "daily_limit" }, 502);

  let question = "Hi, do you have chocolate cake today?";
  const body = await req.json().catch(() => ({}));
  if (typeof body.question === "string" && body.question.trim()) question = body.question.slice(0, 1000);

  // A slow AI must not block staff: after 20 s the app shows the template replies instead.
  let res: Response;
  try {
    res = await fetch(GEMINI_URL, {
      signal: AbortSignal.timeout(20_000),
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": key },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ text: "You draft short, polite replies for staff at Mawar Cake House, a halal cake shop. Staff check every reply before sending. Never invent prices or stock." }],
        },
        contents: [{ role: "user", parts: [{ text: question }] }],
      }),
    });
  } catch (e) {
    console.error("Gemini timeout or network error", e);
    return json({ error: "AI is unavailable, use a template reply", status: 0 }, 502);
  }
  console.log("Gemini answered", res.status);

  if (!res.ok) {
    // Never pass Google's raw error back: it can echo request details.
    console.error("Gemini error", res.status, await res.text());
    return json({ error: "AI is unavailable, use a template reply", status: res.status }, 502);
  }
  const draft = extractText(await res.json());
  // Gemini can answer 200 with no text (for example a safety block): treat it like an outage.
  if (!draft) return json({ error: "AI is unavailable, use a template reply", status: 200 }, 502);
  return json({ question, draft });
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), { status, headers: { ...CORS, "Content-Type": "application/json" } });
}

if (import.meta.main) Deno.serve(handler);
