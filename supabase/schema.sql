-- 商品紀錄系統 schema
-- 在 Supabase Dashboard → SQL Editor 整段貼上執行。整份可以重複執行（改版時再跑一次就會補上新欄位）。
-- 權限設計：只有「已登入」的帳號能讀寫（給你和合夥人用）。
-- 請到 Authentication → Sign In / Providers 關掉「Allow new users to sign up」，
-- 再到 Authentication → Users 手動 Add user，避免陌生人自己註冊進來。

create extension if not exists pgcrypto;

-- 一筆購買（一張圖、一個購買網址，可能含多隻）
create table if not exists public.purchases (
  id            uuid primary key default gen_random_uuid(),
  created_by    uuid default auth.uid() references auth.users(id) on delete set null,
  title         text not null default '',
  source_url    text,
  image_path    text,             -- Storage 內的路徑（item-photos bucket）
  image_url     text,             -- 或者直接用外部圖片網址
  purchase_date date not null default current_date,
  price_jpy     numeric(12,0),    -- 原價（日幣）
  rate          numeric(10,5),    -- 匯率 JPY→TWD
  paid_twd      numeric(12,0),    -- 實際購買價（台幣）；null = 原價 × 匯率
  shipping      numeric(12,0) not null default 0,  -- 運費
  fee           numeric(12,0) not null default 0,  -- 手續費
  discount      numeric(12,0) not null default 0,  -- 折扣（台幣金額）
  tags          text[] not null default '{}',
  note          text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- 每一隻
create table if not exists public.units (
  id          uuid primary key default gen_random_uuid(),
  purchase_id uuid not null references public.purchases(id) on delete cascade,
  sort        int not null default 0,
  name        text not null default '',
  price_jpy   numeric(12,0),     -- 這隻在原始網頁上的日幣價（用來分攤成本，可留空）
  list_price  numeric(12,0),     -- 定價（台幣）
  status      text not null default 'stock' check (status in ('stock','reserved','sold')),
  sold_price  numeric(12,0),     -- 實際賣出價
  sold_date   date,
  buyer       text,
  created_at  timestamptz not null default now()
);

-- v3：購買平台、進貨稅金
alter table public.purchases add column if not exists platform text;                         -- BNS、台灣煤爐…
alter table public.purchases add column if not exists buy_tax  numeric(12,0) not null default 0; -- 進貨稅金（計入總成本）

-- v2：每一隻的圖片、售出資訊、稅金
alter table public.units add column if not exists image_path   text;
alter table public.units add column if not exists tax          numeric(12,0);
alter table public.units add column if not exists sold_place   text;   -- 售出位置（蝦皮、社團、場販…）
alter table public.units add column if not exists trade_method text;   -- 交易方式（賣貨便、面交…）

create index if not exists units_purchase_idx on public.units(purchase_id);
create index if not exists purchases_date_idx on public.purchases(purchase_date desc);
create index if not exists purchases_tags_idx on public.purchases using gin(tags);

create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$ begin new.updated_at = now(); return new; end $$;
drop trigger if exists purchases_touch on public.purchases;
create trigger purchases_touch before update on public.purchases
  for each row execute function public.touch_updated_at();

-- RLS：只有登入的人能讀寫
alter table public.purchases enable row level security;
alter table public.units     enable row level security;

drop policy if exists "auth all purchases" on public.purchases;
create policy "auth all purchases" on public.purchases
  for all to authenticated using (true) with check (true);

drop policy if exists "auth all units" on public.units;
create policy "auth all units" on public.units
  for all to authenticated using (true) with check (true);

-- 照片空間（私有，網頁用短期簽名網址顯示）
insert into storage.buckets (id, name, public)
values ('item-photos', 'item-photos', false)
on conflict (id) do nothing;

drop policy if exists "auth read photos"   on storage.objects;
drop policy if exists "auth write photos"  on storage.objects;
drop policy if exists "auth update photos" on storage.objects;
drop policy if exists "auth delete photos" on storage.objects;
create policy "auth read photos"   on storage.objects for select to authenticated using (bucket_id = 'item-photos');
create policy "auth write photos"  on storage.objects for insert to authenticated with check (bucket_id = 'item-photos');
create policy "auth update photos" on storage.objects for update to authenticated using (bucket_id = 'item-photos');
create policy "auth delete photos" on storage.objects for delete to authenticated using (bucket_id = 'item-photos');
