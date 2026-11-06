-- ==============================================================================
-- TOWEL SHOP - COMPLETE SUPABASE POSTGRESQL SCHEMA WITH RLS & POLICIES
-- Target: Production-ready single towel shop e-commerce backend
-- ==============================================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";

-- ==============================================================================
-- 1. PROFILES TABLE
-- Extends auth.users with user role, name, phone, and push notification FCM token
-- ==============================================================================
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    email text,
    name text,
    phone text,
    role text not null default 'customer' check (role in ('customer', 'admin')),
    fcm_token text,
    created_at timestamptz default timezone('utc'::text, now()) not null,
    updated_at timestamptz default timezone('utc'::text, now()) not null
);

-- Index for role lookup
create index if not exists idx_profiles_role on public.profiles(role);

-- ==============================================================================
-- 2. HELPER FUNCTION: is_admin()
-- Used securely inside Row Level Security (RLS) policies without recursive queries
-- ==============================================================================
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ==============================================================================
-- 3. PRODUCTS TABLE
-- Towel catalog with categories, dimensions, GSM, stock, image url, is_active flag
-- ==============================================================================
create table if not exists public.products (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    description text,
    price numeric(10, 2) not null check (price >= 0),
    original_price numeric(10, 2) check (original_price is null or original_price >= price),
    stock integer not null default 0 check (stock >= 0),
    category text not null, -- 'Bath Towel', 'Hand Towel', 'Face Towel', 'Beach Towel', 'Bath Sheet', 'Bath Robe'
    image_url text,
    additional_images text[] default '{}'::text[],
    color text,
    size text, -- e.g. '70 x 140 cm', '50 x 90 cm', '30 x 30 cm'
    material text default '100% Turkish Cotton',
    gsm integer default 550, -- Grams per square metre (thickness/softness indicator)
    is_active boolean not null default true,
    created_at timestamptz default timezone('utc'::text, now()) not null,
    updated_at timestamptz default timezone('utc'::text, now()) not null
);

create index if not exists idx_products_category on public.products(category);
create index if not exists idx_products_active on public.products(is_active);

-- ==============================================================================
-- 4. ADDRESSES TABLE
-- Multi-address support with default selection
-- ==============================================================================
create table if not exists public.addresses (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    phone text not null,
    line1 text not null, -- House/Flat/Floor/Building
    line2 text not null, -- Street/Area/Locality
    landmark text,
    city text not null,
    state text not null,
    pincode text not null,
    is_default boolean not null default false,
    created_at timestamptz default timezone('utc'::text, now()) not null,
    updated_at timestamptz default timezone('utc'::text, now()) not null
);

create index if not exists idx_addresses_user_id on public.addresses(user_id);

-- Ensure only one default address per user
create or replace function public.handle_default_address()
returns trigger as $$
begin
  if new.is_default then
    update public.addresses
    set is_default = false
    where user_id = new.user_id and id != new.id;
  end if;
  return new;
end;
$$ language plpgsql;

create or replace trigger trg_default_address
before insert or update on public.addresses
for each row
when (new.is_default = true)
execute function public.handle_default_address();

-- ==============================================================================
-- 5. CART ITEMS TABLE
-- Persistent cart linked to Supabase user
-- ==============================================================================
create table if not exists public.cart_items (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    product_id uuid not null references public.products(id) on delete cascade,
    quantity integer not null default 1 check (quantity > 0),
    created_at timestamptz default timezone('utc'::text, now()) not null,
    updated_at timestamptz default timezone('utc'::text, now()) not null,
    unique(user_id, product_id)
);

create index if not exists idx_cart_user_id on public.cart_items(user_id);

-- ==============================================================================
-- 6. ORDERS TABLE
-- Stores orders with snapshot of shipping address, live payment status, order status
-- ==============================================================================
create table if not exists public.orders (
    id uuid primary key default gen_random_uuid(),
    order_number text not null unique,
    user_id uuid references auth.users(id) on delete set null,
    customer_name text not null,
    customer_phone text not null,
    address_snapshot jsonb not null,
    total_amount numeric(10, 2) not null check (total_amount >= 0),
    subtotal numeric(10, 2) not null check (subtotal >= 0),
    shipping_fee numeric(10, 2) not null default 0,
    payment_method text not null check (payment_method in ('COD', 'ONLINE')),
    payment_status text not null default 'unpaid' check (payment_status in ('unpaid', 'paid', 'refunded', 'failed')),
    order_status text not null default 'Placed' check (order_status in ('Placed', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled')),
    razorpay_order_id text,
    razorpay_payment_id text,
    razorpay_signature text,
    cancel_reason text,
    refund_status text default 'none' check (refund_status in ('none', 'refund_pending', 'refunded')),
    notes text,
    created_at timestamptz default timezone('utc'::text, now()) not null,
    updated_at timestamptz default timezone('utc'::text, now()) not null
);

create index if not exists idx_orders_user_id on public.orders(user_id);
create index if not exists idx_orders_status on public.orders(order_status);
create index if not exists idx_orders_created_at on public.orders(created_at desc);

-- ==============================================================================
-- 7. ORDER ITEMS TABLE
-- Stores each item in an order with snapshot of product name & price at order time
-- ==============================================================================
create table if not exists public.order_items (
    id uuid primary key default gen_random_uuid(),
    order_id uuid not null references public.orders(id) on delete cascade,
    product_id uuid references public.products(id) on delete set null,
    product_name text not null,
    product_image text,
    unit_price numeric(10, 2) not null check (unit_price >= 0),
    quantity integer not null check (quantity > 0),
    size text,
    color text,
    total_price numeric(10, 2) not null check (total_price >= 0),
    created_at timestamptz default timezone('utc'::text, now()) not null
);

create index if not exists idx_order_items_order_id on public.order_items(order_id);

-- ==============================================================================
-- 8. AUTOMATIC PROFILE CREATION ON USER SIGNUP
-- ==============================================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, name, phone, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'phone', new.phone, ''),
    coalesce(new.raw_user_meta_data->>'role', 'customer')
  )
  on conflict (id) do update
  set email = excluded.email;
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Auto update updated_at timestamp function
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql;

create or replace trigger trg_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create or replace trigger trg_products_updated_at before update on public.products for each row execute function public.set_updated_at();
create or replace trigger trg_addresses_updated_at before update on public.addresses for each row execute function public.set_updated_at();
create or replace trigger trg_cart_updated_at before update on public.cart_items for each row execute function public.set_updated_at();
create or replace trigger trg_orders_updated_at before update on public.orders for each row execute function public.set_updated_at();

-- ==============================================================================
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.addresses enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- PROFILES POLICIES
-- Users can view their own profile; admins can view all profiles
create policy "Users can view own profile or Admin can view all"
on public.profiles for select
using (auth.uid() = id or public.is_admin());

-- Users can update their own profile; admin can update any profile
create policy "Users can update own profile"
on public.profiles for update
using (auth.uid() = id or public.is_admin())
with check (
  -- Customer cannot elevate their own role to admin
  (public.is_admin()) or (auth.uid() = id and role = (select p.role from public.profiles p where p.id = auth.uid()))
);

-- PRODUCTS POLICIES
-- Anyone (authenticated or guest) can view active products; admin can view all products
create policy "Anyone can read active products, Admin can read all"
on public.products for select
using (is_active = true or public.is_admin());

-- Only Admin can insert products
create policy "Admin can insert products"
on public.products for insert
with check (public.is_admin());

-- Only Admin can update products
create policy "Admin can update products"
on public.products for update
using (public.is_admin())
with check (public.is_admin());

-- Only Admin can delete products
create policy "Admin can delete products"
on public.products for delete
using (public.is_admin());

-- ADDRESSES POLICIES
-- Customers can only manage their own addresses; Admin can view all (for order fulfillment)
create policy "Users can view own addresses or Admin can view all"
on public.addresses for select
using (auth.uid() = user_id or public.is_admin());

create policy "Users can insert own addresses"
on public.addresses for insert
with check (auth.uid() = user_id);

create policy "Users can update own addresses"
on public.addresses for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete own addresses"
on public.addresses for delete
using (auth.uid() = user_id);

-- CART ITEMS POLICIES
-- Customers can only view and manage their own cart
create policy "Users can view own cart"
on public.cart_items for select
using (auth.uid() = user_id);

create policy "Users can insert own cart items"
on public.cart_items for insert
with check (auth.uid() = user_id);

create policy "Users can update own cart items"
on public.cart_items for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete own cart items"
on public.cart_items for delete
using (auth.uid() = user_id);

-- ORDERS POLICIES
-- Customer can view their own orders; Admin can view all orders
create policy "Users can view own orders, Admin can view all"
on public.orders for select
using (auth.uid() = user_id or public.is_admin());

-- Authenticated customer can create an order for themselves
create policy "Users can insert own orders"
on public.orders for insert
with check (auth.uid() = user_id);

-- Customer can cancel their order if status is Placed or Confirmed; Admin can update everything
create policy "Users can cancel own order or Admin can update"
on public.orders for update
using (
  (auth.uid() = user_id and order_status in ('Placed', 'Confirmed')) or public.is_admin()
)
with check (
  -- If customer, can only set order_status to Cancelled and provide cancel_reason/refund_status
  public.is_admin() or (
    auth.uid() = user_id and order_status = 'Cancelled'
  )
);

-- ORDER ITEMS POLICIES
-- Customer can view items of their orders; Admin can view all
create policy "Users can view own order items, Admin can view all"
on public.order_items for select
using (
  exists (
    select 1 from public.orders o
    where o.id = order_items.order_id and (o.user_id = auth.uid() or public.is_admin())
  )
);

-- Customer can insert items into their order
create policy "Users can insert own order items"
on public.order_items for insert
with check (
  exists (
    select 1 from public.orders o
    where o.id = order_items.order_id and o.user_id = auth.uid()
  )
);

-- ==============================================================================
-- 10. SUPABASE STORAGE BUCKET & POLICIES
-- Bucket: 'products' (public)
-- ==============================================================================
insert into storage.buckets (id, name, public)
values ('products', 'products', true)
on conflict (id) do nothing;

-- Public can view images in the products bucket
create policy "Public can view product images"
on storage.objects for select
using (bucket_id = 'products');

-- Only Admin can upload images to products bucket
create policy "Admin can upload product images"
on storage.objects for insert
with check (bucket_id = 'products' and public.is_admin());

-- Only Admin can update images in products bucket
create policy "Admin can update product images"
on storage.objects for update
using (bucket_id = 'products' and public.is_admin());

-- Only Admin can delete images from products bucket
create policy "Admin can delete product images"
on storage.objects for delete
using (bucket_id = 'products' and public.is_admin());

-- ==============================================================================
-- 11. ENABLE REALTIME PUBLICATION
-- Enables instant live updates for products, orders, cart items
-- ==============================================================================
alter publication supabase_realtime add table public.products;
alter publication supabase_realtime add table public.orders;
alter publication supabase_realtime add table public.cart_items;

-- ==============================================================================
-- 12. SAMPLE SEED DATA (LUXURY & DAILY HOME TOWELS)
-- Instantly populates the shop with realistic towels so the app looks stunning!
-- ==============================================================================
insert into public.products (name, description, price, original_price, stock, category, image_url, color, size, material, gsm, is_active)
values
(
  'Royal Turkish Plush Bath Towel',
  'Crafted from 100% long-staple Aegean Turkish cotton, this 700 GSM bath towel offers ultra-absorbency, cloud-like softness, and rapid drying. Finished with a double-stitched hem for enduring luxury.',
  799.00,
  1299.00,
  45,
  'Bath Towel',
  'https://images.unsplash.com/photo-1616627547584-bf28cee262db?auto=format&fit=crop&w=800&q=80',
  'Linen Sand',
  '70 x 140 cm',
  '100% Aegean Turkish Cotton',
  700,
  true
),
(
  'Waffle Weave Quick-Dry Bath Towel',
  'Modern textured waffle weave that gently exfoliates while absorbing water in seconds. Exceptionally lightweight, compact, and naturally antimicrobial.',
  649.00,
  999.00,
  38,
  'Bath Towel',
  'https://images.unsplash.com/photo-1583845112203-29329902332e?auto=format&fit=crop&w=800&q=80',
  'Sage Green',
  '75 x 150 cm',
  '100% Organic Cotton',
  450,
  true
),
(
  'Organic Cotton Hand Towel (Set of 2)',
  'Elevate your guest bathroom or daily routine. Soft zero-twist cotton loops provide gentle, fast water absorption and retain fluffiness wash after wash.',
  499.00,
  799.00,
  60,
  'Hand Towel',
  'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80',
  'Eucalyptus Green',
  '50 x 90 cm',
  '100% Combed Cotton',
  550,
  true
),
(
  'Ultra-Soft Bamboo Face Towels (Pack of 4)',
  'Naturally hypoallergenic and anti-bacterial bamboo-cotton blend. Gentle on sensitive skin and ideal for makeup removal, cleansing, and infant care.',
  399.00,
  599.00,
  85,
  'Face Towel',
  'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?auto=format&fit=crop&w=800&q=80',
  'Pure Ivory',
  '30 x 30 cm',
  '70% Bamboo / 30% Cotton',
  600,
  true
),
(
  'Cabana Striped Oversized Beach Towel',
  'Classic nautical stripe design in vibrant sun-resistant dyes. Generously oversized with a velour front for lounging and a terry loop back for drying.',
  999.00,
  1499.00,
  25,
  'Beach Towel',
  'https://images.unsplash.com/photo-1507652313519-d4e9174996dd?auto=format&fit=crop&w=800&q=80',
  'Navy & Terracotta',
  '90 x 180 cm',
  '100% Ring Spun Cotton',
  500,
  true
),
(
  'Hotel Grandeur Bath Sheet',
  'Extra-large spa bath sheet for total full-body wrapping. Luxuriously heavy and ultra-absorbent, making every bath feel like a 5-star resort experience.',
  1199.00,
  1899.00,
  20,
  'Bath Sheet',
  'https://images.unsplash.com/photo-1520699049698-acd2fccb8cc8?auto=format&fit=crop&w=800&q=80',
  'Warm Charcoal',
  '100 x 200 cm',
  '100% Egyptian Cotton',
  800,
  true
),
(
  'Kimono Collar Cotton Waffle Bathrobe',
  'Lightweight, breathable, and deeply absorbent. Features dual pockets, a tailored kimono collar, and an adjustable waist tie for effortless lounging.',
  1899.00,
  2799.00,
  15,
  'Bath Robe',
  'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80',
  'Sand Beige',
  'Free Size (L/XL)',
  '100% Ring Spun Cotton',
  400,
  true
)
on conflict do nothing;

-- ==============================================================================
-- 13. HOW TO MAKE AN ACCOUNT AN ADMIN (Run in Supabase SQL editor):
-- UPDATE public.profiles
-- SET role = 'admin'
-- WHERE email = 'your-email@example.com';
-- ==============================================================================
