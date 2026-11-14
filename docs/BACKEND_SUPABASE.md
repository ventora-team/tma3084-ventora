# Backend: Supabase

Owner: Nasriq (backend and AI). Covers the tasks from 14 Nov: tables, username login, public QR menu, Gemini test call.

Live project: `mawar-cake-house` (free plan, Singapore), https://pdnhqcjlyszohoxnxzeg.supabase.co , in Nasriq's Supabase organization. All three migrations are applied. Ask Nasriq to invite you to the organization if you need the dashboard.

## Files

| File | What it does |
|---|---|
| `supabase/migrations/20261114000000_core_tables.sql` | Tables for users (`profiles`), menu (`products`, `product_sizes`), orders (`orders`, `order_items`) and points (`points_ledger`, `points_balance`), with access rules |
| `supabase/migrations/20261114000100_public_menu.sql` | The read-only `public_menu` view for the QR page |
| `supabase/migrations/20261114000200_security_fixes.sql` | Fixes from the Supabase security advisor |
| `supabase/functions/gemini-test/` | One Gemini test call, key kept in Supabase secrets |

Money is stored in sen (`6000` = RM 60.00) so totals never round wrong.

## Who can do what

| | Not logged in (QR page) | Staff | Owner |
|---|---|---|---|
| Menu | `public_menu` only, available items, no points | Read, change photo and availability | Everything |
| Orders | No | Read, add, update | Also delete |
| Points | No | Read, add earn or redeem rows | Also delete mistakes |
| Staff accounts | No | Read names | Add, edit, deactivate |

## Username login (checked against the Supabase docs, 14 Nov)

Supabase Auth has **no username login**. It signs people in with email, phone, social accounts or anonymously. The usual workaround, which we use:

1. Each staff account gets a hidden email made from the username: `siti` becomes `siti@mawarcake.example.com`. `example.com` is reserved, so no real mail can ever go there.
2. The app shows only a username box. Before signing in it does:
   ```dart
   await supabase.auth.signInWithPassword(
     email: '${username.trim().toLowerCase()}@mawarcake.example.com',
     password: password,
   );
   ```
3. A database trigger makes the `profiles` row from the email (or from `username` in the account metadata). Usernames are 3 to 30 characters, lower case letters, numbers and `_`. A second account with the same username is rejected; the staff screen shows that as the duplicate-name warning.
4. **Every new account starts as inactive staff** and can see nothing until it is switched on. The role is never taken from the sign-up details, because whoever signs up types those.

Settings to change in the Supabase dashboard (Authentication):
- Turn **off** "Allow new users to sign up", so only the owner can add staff.
- Turn **off** "Confirm email", since the emails are not real.

Adding staff for Demo 1: Dashboard, Authentication, Add user, email `<username>@mawarcake.example.com`, set a password, tick auto confirm. Then in the SQL editor switch them on (and make the owner an owner once):
```sql
update profiles set active = true where username = '<username>';
update profiles set role = 'owner', active = true where username = '<owner username>';
```

Not done yet: the in-app "add staff" and "reset password" buttons. They need the admin key, so they must run in an Edge Function, never in the app.

## Public QR menu API

No login. The QR code opens a small web page that calls:

```
GET https://<project-ref>.supabase.co/rest/v1/public_menu?select=*
apikey: <publishable (anon) key>
```

Example answer:
```json
[{ "id": 1, "name": "Chocolate cake", "description": "", "category": "",
   "photo_url": null, "halal": true,
   "sizes": [{ "label": "6 inch", "price_sen": 6000 }, { "label": "8 inch", "price_sen": 8500 }] }]
```

Filter by category: `...public_menu?category=eq.Cakes`. The publishable key is safe to put in the web page; the access rules above stop it from reading anything else.

Logged-out visitors can read only available products and only the columns in the example (no points), and sizes of those products. Checked on the live project 14 Nov: `public_menu` works, while `products?select=points`, `orders` and `profiles` give "permission denied" or an empty list.

The Supabase security advisor still shows two warnings: signed-in users can call `is_owner` and `is_staff`. That is on purpose: the access rules need them, and they only answer yes or no about the caller.

## Gemini test call

Setup (the owner of the Supabase project does this, the key never goes in the repo or the app):
```
supabase secrets set GEMINI_API_KEY=<your key>
supabase functions deploy gemini-test
```

Deployed on 14 Nov (works without the key, it just answers "GEMINI_API_KEY is not set"). Supabase's own login check also lets the public key through, so the function checks that the caller is an **active staff** account first and answers 401 "Staff login required" otherwise. Checked live: no token and the public key both get 401.

Call it as a signed-in staff member:
```
POST https://<project-ref>.supabase.co/functions/v1/gemini-test
Authorization: Bearer <user's access token>
{"question": "Do you have pandan cake on Saturday?"}
```
Answer: `{"question": "...", "draft": "..."}`. If Gemini fails or the daily limit is hit it answers 502 with "AI is unavailable, use a template reply", which is when the app shows the canned templates (FR-AI-01).

It uses the model name `gemini-flash-latest` so it keeps working when Google renames models.

## How this was tested

- `deno test --allow-env` in `supabase/functions/gemini-test` (6 tests, Gemini and the staff check are faked).
- The two migrations were run in an in-memory Postgres (PGlite) with a stand-in for Supabase's `auth` schema, checking: the trigger makes profiles, duplicate usernames fail, not-logged-in users see only `public_menu`, staff add orders but cannot delete them or change points, expired points do not count, staff cannot make themselves owner.
- On the live project: the security advisor (only the two intended warnings left) and the public menu calls above. Username login and a real Gemini answer are not tested live yet.

## Left for later

- Vouchers (stack with points), inventory batches, complaints table, activity log.
- Points are not matched to the earn rows they use up, so if earned points expire after part of them was redeemed the balance can show too low. Fine for Demo 1.
