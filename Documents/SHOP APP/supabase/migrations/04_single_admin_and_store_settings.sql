-- ==============================================================================
-- TOWEL SHOP - MIGRATION 04: STRICT SINGLE ADMIN LOCK & STORE SETTINGS
-- 1. Restricts admin role exclusively to 'kritikkhodiyar45@gmail.com'
-- 2. Prevents any other registered user from ever becoming admin
-- 3. Creates public.store_settings for Shop Status (Open/Closed), Notice & Admin Security Key
-- ==============================================================================

-- 1. Demote any other accounts and ensure only Kritik is admin
update public.profiles
set role = 'customer'
where email != 'kritikkhodiyar45@gmail.com';

update public.profiles
set role = 'admin'
where email = 'kritikkhodiyar45@gmail.com';

-- 2. Restrict is_admin() function strictly to the single owner email
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and role = 'admin'
      and email = 'kritikkhodiyar45@gmail.com'
  );
$$;

-- 3. Update handle_new_user() trigger: NO ONE can self-register as admin
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, name, phone, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'phone', new.phone, ''),
    case 
      when new.email = 'kritikkhodiyar45@gmail.com' then 'admin'
      else 'customer'
    end
  )
  on conflict (id) do update
  set 
    email = excluded.email,
    role = case 
      when excluded.email = 'kritikkhodiyar45@gmail.com' then 'admin'
      else 'customer'
    end;
  return new;
end;
$$ language plpgsql security definer;

-- 4. Create public.store_settings table
create table if not exists public.store_settings (
  id text primary key default 'primary',
  shop_name text not null default 'Towel Town',
  admin_phone text not null default '+91 98765 43210',
  is_shop_closed boolean not null default false,
  shop_closed_notice text not null default 'Shop is closed for some days so we cannot deliver your product right now.',
  admin_security_pin text not null default '8845',
  updated_at timestamptz default now()
);

-- Seed primary settings if not already present
insert into public.store_settings (id, shop_name, admin_phone, is_shop_closed, shop_closed_notice, admin_security_pin)
values (
  'primary',
  'Towel Town',
  '+91 98765 43210',
  false,
  'Shop is closed for some days so we cannot deliver your product right now.',
  '8845'
)
on conflict (id) do nothing;

-- 5. RLS policies on store_settings
alter table public.store_settings enable row level security;

drop policy if exists "Anyone can read store settings" on public.store_settings;
drop policy if exists "Only admin can update store settings" on public.store_settings;
drop policy if exists "Only admin can insert store settings" on public.store_settings;

create policy "Anyone can read store settings"
on public.store_settings for select
using (true);

create policy "Only admin can update store settings"
on public.store_settings for update
using (public.is_admin())
with check (public.is_admin());

create policy "Only admin can insert store settings"
on public.store_settings for insert
with check (public.is_admin());

-- 6. Add store_settings to realtime publication
do $$
begin
  if not exists (
    select 1 from pg_publication_tables 
    where pubname = 'supabase_realtime' and tablename = 'store_settings'
  ) then
    alter publication supabase_realtime add table public.store_settings;
  end if;
end;
$$;
