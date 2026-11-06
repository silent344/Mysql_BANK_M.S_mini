-- ==============================================================================
-- TOWEL SHOP - MIGRATION 05: FIX PROFILES RLS & ROBUST ADMIN PRIVILEGES
-- 1. Adds insert policy to public.profiles so new customers can save their profile
-- 2. Enhances is_admin() to check auth.jwt()->>'email' directly
-- 3. Ensures store owner profile is seeded if user exists in auth.users
-- 4. Allows live profile and store_settings updates
-- ==============================================================================

-- 1. Enhanced is_admin() function checking both JWT claim and profiles table
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select (
    coalesce(auth.jwt() ->> 'email', '') = 'kritikkhodiyar45@gmail.com'
    or exists (
      select 1 from public.profiles
      where id = auth.uid()
        and role = 'admin'
        and email = 'kritikkhodiyar45@gmail.com'
    )
  );
$$;

-- 2. Drop existing profiles policies
drop policy if exists "Users can view own profile or Admin can view all" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Users can insert own profile" on public.profiles;
drop policy if exists "Anyone can insert profile during signup" on public.profiles;

-- 3. Re-create robust policies on profiles
create policy "Users can view own profile or Admin can view all"
on public.profiles for select
using (auth.uid() = id or public.is_admin());

create policy "Users can insert own profile"
on public.profiles for insert
with check (auth.uid() = id or public.is_admin());

create policy "Users can update own profile"
on public.profiles for update
using (auth.uid() = id or public.is_admin())
with check (
  (public.is_admin()) or (auth.uid() = id and role = 'customer')
);

-- 4. Sync Kritik's profile if user exists in auth.users
do $$
begin
  if exists (select 1 from auth.users where email = 'kritikkhodiyar45@gmail.com') then
    insert into public.profiles (id, email, name, phone, role)
    select id, email, coalesce(raw_user_meta_data->>'name', 'Kritik Khodiyar'), coalesce(raw_user_meta_data->>'phone', '+91 98765 43210'), 'admin'
    from auth.users
    where email = 'kritikkhodiyar45@gmail.com'
    on conflict (id) do update set role = 'admin', email = 'kritikkhodiyar45@gmail.com';
  end if;
end;
$$;

-- 5. Robust policies for store_settings
drop policy if exists "Anyone can read store settings" on public.store_settings;
drop policy if exists "Only admin can update store settings" on public.store_settings;
drop policy if exists "Only admin can insert store settings" on public.store_settings;

create policy "Anyone can read store settings"
on public.store_settings for select
using (true);

create policy "Only admin can update store settings"
on public.store_settings for update
using (public.is_admin() or coalesce(auth.jwt() ->> 'email', '') = 'kritikkhodiyar45@gmail.com')
with check (public.is_admin() or coalesce(auth.jwt() ->> 'email', '') = 'kritikkhodiyar45@gmail.com');

create policy "Only admin can insert store settings"
on public.store_settings for insert
with check (public.is_admin() or coalesce(auth.jwt() ->> 'email', '') = 'kritikkhodiyar45@gmail.com');
