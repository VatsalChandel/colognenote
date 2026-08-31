-- ============================================================
--  Milestone 1 — auth support
--  Run after supabase-schema.sql, in the Supabase SQL editor. Safe to re-run.
--
--  WHY: Phase 1 RLS on `profiles` is owner-only (`id = auth.uid()`), so the app
--  cannot query whether a username is already taken by *another* user. This
--  SECURITY DEFINER function answers exactly that one question — a boolean, no
--  row data — without opening `profiles` up to public reads.
-- ============================================================

create or replace function public.username_available(candidate text)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select not exists (
    select 1 from public.profiles
    where lower(username) = lower(trim(candidate))
  );
$$;

revoke all on function public.username_available(text) from public;
grant execute on function public.username_available(text) to anon, authenticated;

-- Case-insensitive uniqueness guard (the column is already UNIQUE, but that is
-- case-sensitive). Belt-and-braces so "Vatsal" and "vatsal" can't both exist.
create unique index if not exists profiles_username_lower_key
  on public.profiles (lower(username));
