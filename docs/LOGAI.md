# AI Usage Log (LOGAI)

One entry per significant AI-assisted piece of work, using the fields from section 4.2 of the assessment guidelines. Add new entries at the bottom with the next ID (AI-002, AI-003, ...).

---

## AI-001

- **Date:** 14 Nov 2026
- **Owner:** Nasriq (Backend and AI)
- **Target Feature / Module:** Supabase backend: tables and access rules (`supabase/migrations/`), public QR menu view, username login, `gemini-test` Edge Function (FR-AI-01 base)
- **AI Tool & Model Used:** Claude Code, model Claude Opus 5.5
- **Specification / Prompt Provided:** Adam's task list of 14 Nov for Nasriq (Supabase tables for menu, orders, points and users; confirm username login; public read-only menu API for QR; one Gemini test call through an Edge Function with the key in server secrets), the client meeting 2 minutes (points per product with owner-set expiry, staff and owner photos, 7 staff, no email login), and issue #11 (FR-AI-01, template fallback when AI is down).
- **AI Output Summary:** Three SQL migrations (profiles, products, product sizes, orders, order items, points ledger and balance view, row level security, `public_menu` view, security fixes); a Deno Edge Function that checks the caller is active staff and asks Gemini for a reply draft, falling back to "use a template reply" on error or timeout; Deno unit tests; `docs/BACKEND_SUPABASE.md`.
- **Human Refinement & Debugging:**
  - Problems found during review and testing and fixed before merge: the first trigger let anyone who signs up choose the owner role (now every new account is inactive staff); a column-permission approach blocked the owner too (replaced by a trigger); the Supabase security advisor flagged the public menu view and callable helper functions (fixed in the third migration); Supabase's built-in login check also accepts the public key, so the function now checks for active staff itself.
  - Live test by Nasriq with a PowerShell test script (own account and password): username login worked; the Gemini call first hung (504, then 20 s timeout). Logs and a network probe showed Supabase reached Google in about 20 ms, so the cause was the model's "thinking" step; turned it off and added time limits. Retested: real draft returned.
  - Username login: checked in the Supabase docs that Supabase Auth has no username sign-in; chose to map usernames to hidden `@mawarcake.example.com` emails.
- **Verification & GitHub PR Link:**
  - `deno test --allow-env` in `supabase/functions/gemini-test`: 7 passed.
  - Migrations run in an in-memory Postgres (PGlite) with a stand-in auth schema: 16 access checks passed.
  - Live project checks: public menu readable without login; orders, profiles and points column denied; advisor shows only 2 intended warnings.
  - LOGTEST entries: to be added when the LOGTEST file is merged.
  - PR: https://github.com/ventora-team/tma3084-ventora/pull/18 (reviewer: Zulirfan)

---

## AI-002

- **Date:** 18 Nov 2026
- **Owner:** Nasriq (Backend and AI)
- **Target Feature / Module:** Shared daily AI cap for the `gemini-test` Edge Function (FR-AI-01, SRS Table 11 AI-10)
- **AI Tool & Model Used:** Claude Code, model Claude Opus 5.5
- **Specification / Prompt Provided:** "add the daily cap to the edge function", after the team set AI-10 to 100 requests a day for the whole shop (one cap shared by the business, as in issue #11 and the proposal's Table 6).
- **AI Output Summary:** A migration with an `ai_usage` counter table (one row per day, no direct access) and a `use_ai_quota()` database function that counts one request and refuses after 100 a day in shop time (Kuching); the Edge Function checks it before calling Gemini and answers "use a template reply" with `reason: "daily_limit"` when the cap is used up or cannot be checked; two new Deno tests; doc update in `docs/BACKEND_SUPABASE.md`.
- **Human Refinement & Debugging:**
  - Cap kept inside the database function, not passed in by the caller, so nobody can raise it from the app.
  - Count and check happen in one SQL statement, so two staff asking at once cannot both take the last request.
  - First PGlite run failed with "permission denied for table ai_usage": the test setup lacked Supabase's default table rights, not a fault in the migration. Added them and reran.
- **Verification & GitHub PR Link:**
  - `deno test --allow-env` in `supabase/functions/gemini-test`: 11 passed.
  - All migrations run in PGlite: requests 1 to 100 pass, 101 refused, count stays 100, new day starts again, inactive account refused without using the count, public key refused, users cannot read or reset the counter.
  - Live project: not applied or deployed yet.
  - PR: to be added.
