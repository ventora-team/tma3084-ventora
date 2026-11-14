// One test call to Google Gemini. The key lives only in Supabase secrets:
//   supabase secrets set GEMINI_API_KEY=...
// Supabase checks the caller's login token before this runs (verify_jwt is on by default),
// so only signed-in staff can use up the AI quota.

const GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

export function extractText(body: unknown): string {
  // deno-lint-ignore no-explicit-any
  const parts = (body as any)?.candidates?.[0]?.content?.parts ?? [];
  return parts.map((p: { text?: string }) => p.text ?? "").join("").trim();
}

export async function handler(req: Request): Promise<Response> {
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return json({ error: "GEMINI_API_KEY is not set" }, 500);

  let question = "Hi, do you have chocolate cake today?";
  if (req.method === "POST") {
    const body = await req.json().catch(() => ({}));
    if (typeof body.question === "string" && body.question.trim()) question = body.question.slice(0, 1000);
  }

  const res = await fetch(GEMINI_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json", "x-goog-api-key": key },
    body: JSON.stringify({
      systemInstruction: {
        parts: [{ text: "You draft short, polite replies for staff at Mawar Cake House, a halal cake shop. Staff check every reply before sending. Never invent prices or stock." }],
      },
      contents: [{ role: "user", parts: [{ text: question }] }],
    }),
  });

  if (!res.ok) {
    // Never pass Google's raw error back: it can echo request details.
    console.error("Gemini error", res.status, await res.text());
    return json({ error: "AI is unavailable, use a template reply", status: res.status }, 502);
  }
  return json({ question, draft: extractText(await res.json()) });
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), { status, headers: { "Content-Type": "application/json" } });
}

if (import.meta.main) Deno.serve(handler);
