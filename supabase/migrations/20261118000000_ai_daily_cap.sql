-- Shared daily cap for AI drafts (SRS Table 11, AI-10): 100 requests a day for the whole shop.

-- One row per day. No access rules on purpose: only use_ai_quota() below touches it.
create table public.ai_usage (
  day   date primary key,
  count integer not null default 0
);
alter table public.ai_usage enable row level security;

-- Counts one AI request and answers true while today is still under the cap.
-- "Today" is shop time (Kuching, UTC+8), so the cap resets at midnight in the shop.
-- The insert is one statement, so two staff asking at the same moment cannot both take the last slot.
create function public.use_ai_quota() returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  used integer;
begin
  if not public.is_staff() then
    return false;
  end if;
  insert into public.ai_usage as u (day, count)
  values ((now() at time zone 'Asia/Kuching')::date, 1)
  on conflict (day) do update set count = u.count + 1 where u.count < 100
  returning u.count into used;
  return used is not null;
end;
$$;

revoke execute on function public.use_ai_quota() from public, anon;
grant execute on function public.use_ai_quota() to authenticated;
