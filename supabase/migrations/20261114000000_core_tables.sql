-- Core tables for the Mawar Cake House App: users, menu, orders, points.
-- Money is stored in sen (integer) so totals never have rounding errors.

-- ---------- Users ----------
-- Supabase Auth keeps the login; this table keeps the shop details.
-- Staff log in with a username. The app turns it into "<username>@mawarcake.example.com"
-- before calling Supabase Auth (see docs/BACKEND_SUPABASE.md).
create table public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  username   text not null,
  full_name  text not null default '',
  role       text not null default 'staff' check (role in ('owner', 'staff')),
  active     boolean not null default true,
  created_at timestamptz not null default now(),
  constraint username_format check (username ~ '^[a-z0-9_]{3,30}$')
);
-- Duplicate-name check for the staff accounts screen.
create unique index profiles_username_key on public.profiles (username);

-- Make a profile row whenever an account is created.
-- user_metadata is typed by whoever signs up, so it never sets the role or switches the
-- account on: every new account is inactive staff until the owner activates it.
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, username, full_name, active)
  values (
    new.id,
    lower(coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1))),
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    false
  );
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Helper for policies: is the signed-in user an active owner / active staff member?
create function public.is_owner() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'owner' and active)
$$;

create function public.is_staff() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles where id = auth.uid() and active)
$$;

-- ---------- Menu ----------
create table public.products (
  id           bigint generated always as identity primary key,
  name         text not null,
  description  text not null default '',
  category     text not null default '',
  photo_url    text,                          -- owner and staff upload photos (meeting 2, Req 11)
  halal        boolean not null default true, -- shows the halal / Muslim-owned logo
  available    boolean not null default true,
  points       integer not null default 0 check (points >= 0), -- points per product, set by owner (Req 09)
  created_at   timestamptz not null default now()
);

create table public.product_sizes (
  id          bigint generated always as identity primary key,
  product_id  bigint not null references public.products (id) on delete cascade,
  label       text not null,                  -- for example "6 inch", "1 kg", "box of 6"
  price_sen   integer not null check (price_sen >= 0),
  sort_order  integer not null default 0,
  unique (product_id, label)
);

-- ---------- Orders ----------
create table public.orders (
  id              bigint generated always as identity primary key,
  customer_name   text not null,
  customer_phone  text not null,              -- also the loyalty points key
  channel         text not null check (channel in ('walk_in', 'whatsapp', 'phone', 'tiktok', 'facebook', 'other')),
  allergies       text not null default '',   -- asked first, before anything else
  pickup_at       timestamptz not null,
  status          text not null default 'new' check (status in ('new', 'in_progress', 'ready', 'collected', 'cancelled')),
  deposit_sen     integer not null default 0 check (deposit_sen >= 0),
  payment_method  text check (payment_method in ('cash', 'qr', 'card')),
  notes           text not null default '',
  created_by      uuid references public.profiles (id),
  created_at      timestamptz not null default now()
);

create table public.order_items (
  id              bigint generated always as identity primary key,
  order_id        bigint not null references public.orders (id) on delete cascade,
  product_id      bigint not null references public.products (id),
  size_id         bigint references public.product_sizes (id),
  quantity        integer not null default 1 check (quantity > 0),
  unit_price_sen  integer not null check (unit_price_sen >= 0), -- copied at order time, menu prices can change later
  flavour         text not null default '',
  design          text not null default '',
  cake_message    text not null default ''
);

-- ---------- Points ----------
-- One row per earn (+) or redeem (-). Balance = sum of rows that have not expired.
create table public.points_ledger (
  id              bigint generated always as identity primary key,
  customer_phone  text not null,
  order_id        bigint references public.orders (id) on delete set null,
  points          integer not null check (points <> 0),
  expires_at      timestamptz,                -- owner sets the expiry date (Req 14); null = never
  reason          text not null default '',
  created_by      uuid references public.profiles (id),
  created_at      timestamptz not null default now()
);
create index points_ledger_phone_idx on public.points_ledger (customer_phone);

-- shortcut: redeemed points are not matched to the earn rows they used up, so an
-- expired earn row can make a balance go negative; upgrade to per-batch redemption if that happens.
create view public.points_balance with (security_invoker = true) as
  select customer_phone, sum(points)::integer as balance
  from public.points_ledger
  where expires_at is null or expires_at > now()
  group by customer_phone;

-- ---------- Row level security ----------
alter table public.profiles      enable row level security;
alter table public.products      enable row level security;
alter table public.product_sizes enable row level security;
alter table public.orders        enable row level security;
alter table public.order_items   enable row level security;
alter table public.points_ledger enable row level security;

-- Profiles: staff see everyone's name (for "created by"), only the owner changes them.
create policy "staff read profiles"   on public.profiles for select to authenticated using (public.is_staff());
create policy "owner manages profiles" on public.profiles for all to authenticated using (public.is_owner()) with check (public.is_owner());

-- Menu: staff read, owner edits. Staff may update photos and availability too (Req 11).
create policy "staff read products"    on public.products for select to authenticated using (public.is_staff());
create policy "staff update products"  on public.products for update to authenticated using (public.is_staff()) with check (public.is_staff());
create policy "owner manages products" on public.products for all to authenticated using (public.is_owner()) with check (public.is_owner());
create policy "staff read sizes"       on public.product_sizes for select to authenticated using (public.is_staff());
create policy "owner manages sizes"    on public.product_sizes for all to authenticated using (public.is_owner()) with check (public.is_owner());

-- Staff may only change photo and availability; name, points etc. stay with the owner.
create function public.guard_product_update() returns trigger
language plpgsql set search_path = '' as $$
begin
  -- auth.uid() is null for the dashboard and server code, which are allowed.
  if auth.uid() is not null and not public.is_owner()
     and (to_jsonb(new) - 'photo_url' - 'available') <> (to_jsonb(old) - 'photo_url' - 'available') then
    raise exception 'Only the owner can change this product field';
  end if;
  return new;
end $$;

create trigger guard_product_update before update on public.products
  for each row execute function public.guard_product_update();

-- Orders and items: every active staff member reads and writes; only the owner deletes.
create policy "staff read orders"   on public.orders for select to authenticated using (public.is_staff());
create policy "staff add orders"    on public.orders for insert to authenticated with check (public.is_staff());
create policy "staff update orders" on public.orders for update to authenticated using (public.is_staff()) with check (public.is_staff());
create policy "owner deletes orders" on public.orders for delete to authenticated using (public.is_owner());
create policy "staff manage items"  on public.order_items for all to authenticated using (public.is_staff()) with check (public.is_staff());

-- Points: staff read and add rows (earn or redeem); nobody edits history; owner can delete mistakes.
create policy "staff read points"   on public.points_ledger for select to authenticated using (public.is_staff());
create policy "staff add points"    on public.points_ledger for insert to authenticated with check (public.is_staff());
create policy "owner deletes points" on public.points_ledger for delete to authenticated using (public.is_owner());
