-- ==============================================================================
-- TOWEL SHOP - MIGRATION 03: PRODUCT DELIVERY CHARGE CONTROL
-- Gives store admin control over which product has delivery charges and the amount
-- ==============================================================================

-- 1. Add delivery_charge column to public.products (default 0.00 = Free Delivery)
alter table public.products 
add column if not exists delivery_charge numeric(10, 2) not null default 0.00 check (delivery_charge >= 0);

-- 2. Notify PostgREST to reload schema cache
notify pgrst, 'reload schema';
