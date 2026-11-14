-- Public QR menu: read-only, no login.
-- Customers scan the QR code and the web page calls:
--   GET https://<project>.supabase.co/rest/v1/public_menu?select=*
--   header apikey: <anon / publishable key>
-- Only safe columns are shown, and only products that are available.
-- The view runs with its owner's rights (security definer is the default for views),
-- so anon needs no access to the products tables themselves.
create view public.public_menu as
  select
    p.id,
    p.name,
    p.description,
    p.category,
    p.photo_url,
    p.halal,
    coalesce(
      (select jsonb_agg(jsonb_build_object('label', s.label, 'price_sen', s.price_sen) order by s.sort_order, s.label)
       from public.product_sizes s where s.product_id = p.id),
      '[]'::jsonb
    ) as sizes
  from public.products p
  where p.available;

revoke all on public.public_menu from anon, authenticated;
grant select on public.public_menu to anon, authenticated;
