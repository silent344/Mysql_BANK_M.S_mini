-- ==============================================================================
-- TOWEL SHOP - MIGRATION 02: HARDEN ADMIN PERMISSIONS & POLICIES
-- Ensures store admins can seamlessly insert, update, delete products and manage orders
-- ==============================================================================

-- 1. Ensure Kritik and any admin email is permanently flagged as admin
update public.profiles
set role = 'admin'
where email = 'kritikkhodiyar45@gmail.com' or email ilike '%admin%';

-- 2. Update is_admin() function to reliably check profiles and admin email patterns
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and (
      role = 'admin'
      or email = 'kritikkhodiyar45@gmail.com'
      or email ilike '%admin%'
    )
  );
$$;

-- 3. Update handle_new_user() trigger to automatically grant admin role to admin accounts
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
      when new.email = 'kritikkhodiyar45@gmail.com' or new.email ilike '%admin%' then 'admin'
      else coalesce(new.raw_user_meta_data->>'role', 'customer')
    end
  )
  on conflict (id) do update
  set 
    email = excluded.email,
    role = case 
      when excluded.email = 'kritikkhodiyar45@gmail.com' or excluded.email ilike '%admin%' then 'admin'
      else profiles.role
    end;
  return new;
end;
$$ language plpgsql security definer;

-- 4. Re-apply and verify Product policies for Admin
drop policy if exists "Admin can insert products" on public.products;
drop policy if exists "Admin can update products" on public.products;
drop policy if exists "Admin can delete products" on public.products;
drop policy if exists "Anyone can read active products, Admin can read all" on public.products;

create policy "Anyone can read active products, Admin can read all"
on public.products for select
using (is_active = true or public.is_admin());

create policy "Admin can insert products"
on public.products for insert
with check (public.is_admin());

create policy "Admin can update products"
on public.products for update
using (public.is_admin())
with check (public.is_admin());

create policy "Admin can delete products"
on public.products for delete
using (public.is_admin());

-- 5. Storage Policies: Ensure Admin can upload and delete images in the 'products' bucket
insert into storage.buckets (id, name, public)
values ('products', 'products', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can view product images" on storage.objects;
drop policy if exists "Admin can upload product images" on storage.objects;
drop policy if exists "Admin can update product images" on storage.objects;
drop policy if exists "Admin can delete product images" on storage.objects;

create policy "Public can view product images"
on storage.objects for select
using (bucket_id = 'products');

create policy "Admin can upload product images"
on storage.objects for insert
with check (bucket_id = 'products' and public.is_admin());

create policy "Admin can update product images"
on storage.objects for update
using (bucket_id = 'products' and public.is_admin());

create policy "Admin can delete product images"
on storage.objects for delete
using (bucket_id = 'products' and public.is_admin());
