-- Fixes from the Supabase security advisor (14 Nov).

-- 1. public_menu now follows the access rules of whoever reads it.
--    Logged-out visitors get read access to available products only, and only the safe columns
--    (points stay hidden).
alter view public.public_menu set (security_invoker = true);

revoke select on public.products from anon;
grant select (id, name, description, category, photo_url, halal, available) on public.products to anon;
create policy "public reads available products" on public.products for select to anon using (available);
create policy "public reads sizes of available products" on public.product_sizes for select to anon
  using (exists (select 1 from public.products p where p.id = product_id and p.available));

-- 2. Helper functions are not callable through the public API.
--    is_owner / is_staff stay callable by signed-in users because the access rules use them.
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.is_owner() from public, anon;
revoke execute on function public.is_staff() from public, anon;
grant execute on function public.is_owner(), public.is_staff() to authenticated;
