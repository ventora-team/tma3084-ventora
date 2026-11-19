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

## AI-003

- **Date:** 19 Nov 2026
- **Owner:** Nasriq (Backend and AI)
- **Target Feature / Module:** First Flutter project and the Demo 1 screens for FR-AI-01 (reply drafts) and FR-AI-02 (complaint hand-over): `lib/`, `test/`
- **AI Tool & Model Used:** Claude Code, model Claude Opus 5.5
- **Specification / Prompt Provided:** Adam's Demo 1 split (Nasriq: "Reply draft and complaint hand-over", FR-AI-01 and FR-AI-02), the lecturer's rule that the Flutter app must partly run, and the agreed SRS wording: staff edit and approve every draft, complaints get no AI reply and go to the owner's Complaints page (New or Handled), staff can flag by hand or release a wrongly flagged message back to the reply flow, templates when the AI is down or the 100-a-day cap is used up.
- **AI Output Summary:** `flutter create` at the repo root (Android, Windows and web); CORS headers in the `gemini-test` Edge Function so the web build can call it, with one more Deno test; staff login by username (hidden email, as in `docs/BACKEND_SUPABASE.md`); Reply screen that calls the `gemini-test` Edge Function, shows an editable draft and copies it on approval, or shows template replies when the AI is unavailable; complaint check (English and Malay keywords) that skips the AI; Complaints screen with New and Handled, "Mark handled" and "Release to reply flow"; 7 tests.
- **Human Refinement & Debugging:**
  - Complaints are kept in memory for Demo 1 (marked as a shortcut in the code); the complaints table comes with the full FR-AI-02.
  - A released message is not flagged again, so staff are not stuck in a loop.
  - Two tests first failed: the buttons sat below the small test screen, and the clipboard call never finished without a fake clipboard. Fixed in the tests, not the app.
- **Verification & GitHub PR Link:**
  - `dart format`, `flutter analyze` (no issues), `flutter test --coverage`: 7 passed, 91% line coverage on the tested files.
  - `deno test --allow-env` in `supabase/functions/gemini-test`: 10 passed; the live function answered the browser pre-check with 405 before the change. Deployed 19 Nov (version 8): pre-check 200 with CORS headers, public key and no login still 401.
  - Web build served locally: login screen and its empty-field check work in the browser. Signed-in run with the live AI: pending.
  - PR: https://github.com/ventora-team/tma3084-ventora/pull/21
