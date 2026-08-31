-- ============================================================
--  Milestone 5 — account deletion
--  Run in the Supabase SQL editor. Safe to re-run.
--
--  The app can't delete an auth.users row with the anon key. This
--  SECURITY DEFINER function lets a signed-in user delete their OWN
--  account. Removing the auth.users row cascades:
--    auth.users -> profiles -> collection_items / costs / wear_logs /
--                  compliments / wishlist_items / follows
--  (personal fragrances they submitted have submitted_by set to null,
--   per the schema — they're kept, just unowned.)
-- ============================================================

create or replace function public.delete_own_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_own_account() from public, anon;
grant execute on function public.delete_own_account() to authenticated;
