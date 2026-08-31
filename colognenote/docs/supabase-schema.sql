-- ============================================================
--  Cologne Collection App — Supabase / Postgres schema
--  Run once on a fresh database (Supabase SQL editor).
--
--  Design decisions baked in:
--   * Two-tier fragrances: canonical (shared, social-safe) vs personal (free-text).
--   * Manual adds create a `fragrances` row with tier='personal' — collection
--     items ALWAYS reference a fragrance, never free text.
--   * price lives in its OWN table (collection_item_costs) so it can be kept
--     private while the rest of the shelf is public. Postgres RLS is row-level,
--     not column-level — isolating the private field in its own table is the
--     clean, hard way to hide one field and expose the rest.
--   * accords are DERIVED (a view), not stored — each note rolls up to one family.
--   * Phase 1 RLS = owner-only everything. Phase 2 ADDS public-read policies to
--     the social tables; the costs table never gets one. That's the whole payoff.
-- ============================================================

create extension if not exists pgcrypto;   -- gen_random_uuid()

-- ------------------------------------------------------------
-- 1. Controlled vocabularies as enum types (small, fixed sets)
-- ------------------------------------------------------------
create type fragrance_tier   as enum ('canonical', 'personal');
create type fragrance_status as enum ('pending', 'verified');
create type item_status      as enum ('active', 'finished', 'sold');
create type pyramid_position as enum ('top', 'middle', 'base');
create type wishlist_stage   as enum ('sampled', 'considering', 'want_bottle');

-- concentration & occasion are controlled but may grow, so text + CHECK
-- (easier to extend than an enum; promote to a lookup table later if needed).

-- ------------------------------------------------------------
-- 2. Users  (profiles extends Supabase's built-in auth.users)
-- ------------------------------------------------------------
create table profiles (
  id                   uuid primary key references auth.users (id) on delete cascade,
  username             text unique not null,
  display_name         text,
  avatar_url           text,
  bio                  text,
  show_collection_value boolean not null default false,  -- the one opt-in flex
  created_at           timestamptz not null default now()
);

-- Auto-create a profile row when a new auth user signs up.
create function handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, username)
  values (new.id, coalesce(new.raw_user_meta_data->>'username', 'user_' || left(new.id::text, 8)));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ------------------------------------------------------------
-- 3. Accord families (the fixed list) + notes (the growing list)
-- ------------------------------------------------------------
create table accord_families (
  id   smallint primary key generated always as identity,
  name text unique not null
);

create table notes (
  id        integer primary key generated always as identity,
  name      text unique not null,
  family_id smallint not null references accord_families (id)   -- each note → ONE family
);
create index notes_family_idx on notes (family_id);

-- ------------------------------------------------------------
-- 4. Fragrances (canonical = shared truth; personal = user free-text)
-- ------------------------------------------------------------
create table fragrances (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  house         text,
  concentration text check (concentration in
                  ('EDC','EDT','EDP','Parfum','Extrait','Eau Fraiche','Elixir')),  -- extensible
  year_released smallint,
  image_url     text,
  tier          fragrance_tier   not null default 'personal',
  status        fragrance_status not null default 'pending',
  submitted_by  uuid references profiles (id) on delete set null,  -- null for seed data
  created_at    timestamptz not null default now()
);
create index fragrances_tier_status_idx on fragrances (tier, status);
-- Fast name search for the "add" flow; upgrade to full-text/pg_trgm when it grows.
create index fragrances_name_idx on fragrances (lower(name));

-- Pyramid: which notes sit at top/middle/base of a fragrance
create table fragrance_notes (
  fragrance_id uuid    not null references fragrances (id) on delete cascade,
  note_id      integer not null references notes (id)      on delete cascade,
  position     pyramid_position not null,
  primary key (fragrance_id, note_id, position)
);

-- ------------------------------------------------------------
-- 5. Collection items — one entry per fragrance owned (public-facing fields)
--    NOTE: price is NOT here. It lives in collection_item_costs (private).
-- ------------------------------------------------------------
create table collection_items (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references profiles (id)  on delete cascade,
  fragrance_id      uuid not null references fragrances (id) on delete restrict,
  size_ml           smallint,
  purchase_date     date,
  purchase_location text,
  batch_code        text,
  fill_level        smallint check (fill_level between 0 and 100),  -- rough %, manual
  personal_rating   smallint check (personal_rating between 1 and 5),
  status            item_status not null default 'active',
  photo_url         text,
  created_at        timestamptz not null default now()
);
create index collection_items_user_idx      on collection_items (user_id);
create index collection_items_fragrance_idx on collection_items (fragrance_id);
-- One ACTIVE entry per fragrance per user (history of finished/sold still allowed).
create unique index collection_items_one_active
  on collection_items (user_id, fragrance_id) where status = 'active';

-- price isolated here so RLS can keep it owner-only. user_id duplicated for a
-- trivial, fast RLS check. cost_per_wear = price / count(wears) is computed in-app.
create table collection_item_costs (
  collection_item_id uuid primary key references collection_items (id) on delete cascade,
  user_id            uuid not null references profiles (id) on delete cascade,
  price              numeric(10,2) not null,
  currency           char(3) not null default 'USD'
);

-- ------------------------------------------------------------
-- 6. Logging — wears (the core event) and compliments
-- ------------------------------------------------------------
create table wear_logs (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references profiles (id)         on delete cascade,
  collection_item_id uuid not null references collection_items (id) on delete cascade,
  worn_on            date not null default current_date,
  occasion           text check (occasion in
                       ('office','date','gym','formal','casual','night_out')),  -- extensible
  weather_temp       numeric(4,1),   -- snapshotted at log time
  weather_condition  text,           -- e.g. 'rain', 'clear'
  is_sotd            boolean not null default false,  -- a wear you posted publicly
  pairing            text,
  created_at         timestamptz not null default now()
  -- season is DERIVED from worn_on at query time, not stored.
);
create index wear_logs_user_idx on wear_logs (user_id);
create index wear_logs_item_idx on wear_logs (collection_item_id);

create table compliments (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references profiles (id)         on delete cascade,
  collection_item_id uuid not null references collection_items (id) on delete cascade,
  wear_log_id        uuid references wear_logs (id) on delete set null,  -- nullable = loose
  complimented_on    date not null default current_date,
  who                text,
  comment            text,
  created_at         timestamptz not null default now()
);
create index compliments_user_idx on compliments (user_id);
create index compliments_item_idx on compliments (collection_item_id);

-- ------------------------------------------------------------
-- 7. Social graph + wishlist
-- ------------------------------------------------------------
create table follows (
  follower_id uuid not null references profiles (id) on delete cascade,
  followee_id uuid not null references profiles (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (follower_id, followee_id),
  check (follower_id <> followee_id)
);
create index follows_followee_idx on follows (followee_id);

create table wishlist_items (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references profiles (id) on delete cascade,
  fragrance_id        uuid references fragrances (id) on delete set null,  -- canonical...
  fragrance_freetext  text,                                                -- ...or free text
  stage               wishlist_stage not null default 'considering',
  target_price        numeric(10,2),
  notes               text,
  created_at          timestamptz not null default now(),
  check (fragrance_id is not null or fragrance_freetext is not null)
);
create index wishlist_user_idx on wishlist_items (user_id);

-- ------------------------------------------------------------
-- 8. Derived views
-- ------------------------------------------------------------
-- A fragrance's accords = the distinct families across its notes.
create view fragrance_accords as
  select distinct fn.fragrance_id, af.id as family_id, af.name as family_name
  from fragrance_notes fn
  join notes n            on n.id = fn.note_id
  join accord_families af on af.id = n.family_id;

-- Owner's collection value (active items). RLS on the costs table means this
-- view only ever returns the caller's own total.
create view my_collection_value
  with (security_invoker = on) as
  select c.user_id, sum(c.price) as total_value, count(*) as item_count
  from collection_item_costs c
  join collection_items i on i.id = c.collection_item_id and i.status = 'active'
  group by c.user_id;

-- ============================================================
--  ROW-LEVEL SECURITY
-- ============================================================
alter table profiles              enable row level security;
alter table fragrances            enable row level security;
alter table accord_families       enable row level security;
alter table notes                 enable row level security;
alter table fragrance_notes       enable row level security;
alter table collection_items      enable row level security;
alter table collection_item_costs enable row level security;
alter table wear_logs             enable row level security;
alter table compliments           enable row level security;
alter table follows               enable row level security;
alter table wishlist_items        enable row level security;

-- --- Reference data: verified canonical fragrances + the vocab are world-readable
create policy read_families    on accord_families for select using (true);
create policy read_notes       on notes           for select using (true);
create policy read_pyramid     on fragrance_notes for select using (true);
create policy read_canonical   on fragrances      for select
  using (tier = 'canonical' and status = 'verified');
-- A user can always see the personal/pending fragrances they submitted.
create policy read_own_frag    on fragrances      for select
  using (submitted_by = auth.uid());
-- Any signed-in user can submit a new (personal/pending) fragrance.
create policy insert_frag      on fragrances      for insert to authenticated
  with check (submitted_by = auth.uid());
-- (Verifying/promoting to canonical is done by you via the service role, which
--  bypasses RLS — that's your moderation gate. No public update policy on purpose.)

-- --- PHASE 1: owner-only on everything personal ------------------------------
create policy own_profile_sel  on profiles for select using (id = auth.uid());
create policy own_profile_upd  on profiles for update using (id = auth.uid());

create policy own_items_all    on collection_items      for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_costs_all    on collection_item_costs for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_wears_all    on wear_logs             for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_compl_all    on compliments           for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_wish_all     on wishlist_items        for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_follows_all  on follows               for all
  using (follower_id = auth.uid()) with check (follower_id = auth.uid());

-- ============================================================
--  PHASE 2 — social. ADD these when you turn the public layer on.
--  They open READ access on the shelf; they do NOT touch write rules,
--  and collection_item_costs deliberately gets NOTHING here — which is
--  why price stays private even though wears/ratings become public.
-- ============================================================
-- create policy public_profiles on profiles         for select using (true);
-- create policy public_items    on collection_items for select using (true);
-- create policy public_wears    on wear_logs        for select using (true);
-- create policy public_compl    on compliments      for select using (true);
-- create policy public_follows  on follows          for select using (true);
-- (collection_item_costs: intentionally no public policy, ever.)

-- ============================================================
--  Seed: the fixed 16 accord families
--  (from an original 18: Sweet merged into Gourmand, Animalic merged into Musky)
-- ============================================================
insert into accord_families (name) values
  ('Citrus'), ('Aromatic'), ('Green'), ('Aquatic'), ('Fruity'),
  ('Floral'), ('White Floral'), ('Spicy'), ('Gourmand'), ('Woody'),
  ('Earthy / Mossy'), ('Amber'), ('Powdery'), ('Leather'), ('Smoky'), ('Musky');
