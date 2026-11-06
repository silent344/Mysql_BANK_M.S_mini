# 🛁 SoftTouch Towels - Production E-Commerce Flutter Mobile App

A modern, production-ready e-commerce mobile application built in **Flutter (Dart)** for a luxury single towel & home-textiles shop. Powered by **Supabase** (Auth, Postgres, Realtime, Storage, Edge Functions) and **Razorpay** for secure payments.

---

## 📸 Core Features & Highlights

### 1. Customer Experience
- **Plush Home-Textile UI**: Warm terracotta and linen Material 3 design crafted specifically for bath linens.
- **Product Catalog**: Towel grid with image, price, original price strikethrough, discount badges, GSM indicator (e.g. 700 GSM), search bar, and category filters (*Bath Towel, Hand Towel, Face Towel, Beach Towel, Bath Sheet, Bath Robe*).
- **Product Detail**: High-res imagery, detailed weaving/cotton specifications (Aegean Turkish Cotton, Egyptian Cotton, Waffle Weave), size & color shade badges, stock availability, and quantity controls.
- **Persistent Cart**: Automatically synced to the user's Supabase account (`cart_items` table), dynamic free delivery threshold indicator (e.g. *"Add ₹200 more for FREE Delivery"*), live subtotal and total amount.
- **Address Book**: Add, edit, delete, and select shipping addresses. Automatic single-default address management via PostgreSQL triggers.
- **Checkout & Payments**:
  - **Cash on Delivery (COD)**: Placed with `payment_status = 'unpaid'`.
  - **Online Payment (Razorpay Test Mode)**: Razorpay order creation and HMAC SHA-256 signature verification performed inside **Supabase Edge Functions**. The app client *never* holds the secret key!
- **Instant PDF Invoices**: Generates formatted tax receipts with shop details, customer shipping address, itemized breakdown, tax details, and order status. Supports **Print**, **Share**, and **Download**. Re-downloadable anytime from order history.
- **Order Management & Cancellation**: View order status (*Placed, Confirmed, Shipped, Delivered, Cancelled*). Allows cancellation while status is *Placed* or *Confirmed*, captures optional reason, and automatically marks online payments as `"refund_pending"` for manual admin refunds.

### 2. Admin Panel (Shop Owner)
- **Role-Based Access**: Enforced both in the UI and at the database level via Supabase **Row Level Security (RLS)**.
- **Live Orders Dashboard**: Real-time stream of incoming customer orders, filtering by fulfillment status (*Placed, Confirmed, Shipped, Delivered, Cancelled*) and payment type (*COD / Online*).
- **Fulfillment Controls**: One-tap status updates and a dedicated *"Mark COD as Collected / Paid"* action.
- **Catalog Management**: Add, edit, update prices, change inventory stock, enable/disable products (instant catalog visibility toggle), and delete towels.
- **Supabase Storage Uploads**: Direct photo upload from camera/gallery into the Supabase Storage `products` bucket.
- **Real-Time Sound & Push Alerts**: In-app notifications and sound alerts when customers place or cancel orders.

---

## 🏗️ Architecture & Project Structure

The project follows a clean, feature-driven layered architecture with **Flutter Riverpod**:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Textile terracotta & linen palette
│   │   ├── app_constants.dart     # Categories, sizes, order statuses
│   │   └── app_theme.dart         # Material 3 typography & styling
│   ├── services/
│   │   ├── supabase_service.dart  # Supabase client, auth & profile queries
│   │   ├── notification_service.dart # Local notifications & FCM handlers
│   │   └── pdf_service.dart       # PDF invoice generator & printer
│   ├── utils/
│   │   └── formatters.dart        # Currency (₹) and date formatting
│   └── widgets/                   # CustomButton, CustomTextField, StatusBadge, etc.
├── features/
│   ├── auth/                      # Login, Register, AuthWrapper, UserProfile
│   ├── products/                  # Product model, Provider, Home & Detail screens
│   ├── cart/                      # CartItem model, Provider, CartScreen
│   ├── address/                   # Address model, Provider, AddressList & Form screens
│   ├── checkout/                  # CheckoutScreen with Razorpay integration
│   ├── orders/                    # OrderModel, Provider, MyOrders, Detail & PDF screens
│   ├── admin/                     # AdminProvider, Dashboard, OrderDetail, ProductForm
│   ├── profile/                   # ProfileScreen with role switcher demo
│   └── customer_main_screen.dart  # Bottom navigation shell
└── main.dart                      # App entrypoint with ProviderScope & .env initialization
```

---

## 🚀 Step-by-Step Backend Setup Guide

### Step 1: Create Supabase Project
1. Log in to [Supabase](https://supabase.com) and create a new project (e.g. `towel-shop`).
2. Go to **Project Settings** -> **API**:
   - Copy the **Project URL**.
   - Copy the **anon / public** key.
   - Copy the **service_role** key (keep this secret, used only for Edge Functions).

### Step 2: Run Database Migration SQL
1. In the Supabase Dashboard, open the **SQL Editor**.
2. Click **New Query**, open the file [01_initial_schema.sql](file:///Users/kritikkhodiyar/Documents/SHOP%20APP/supabase/migrations/01_initial_schema.sql) from this repository, paste the entire content, and click **Run**.
3. This creates:
   - Tables: `profiles`, `products`, `addresses`, `cart_items`, `orders`, `order_items`
   - Row Level Security (RLS) policies protecting customer data
   - Automatic user profile trigger on signup (`on_auth_user_created`)
   - Default address uniqueness trigger (`trg_default_address`)
   - Supabase Storage bucket `products` with public read and admin write permissions
   - Realtime publication enabling live updates for `products`, `orders`, and `cart_items`
   - Pre-populated seed catalog with high-quality luxury towel products.

### Step 3: Configure Environment Variables
Copy `.env.example` to `.env` in the root of the project:
```bash
cp .env.example .env
```
Update the keys with your credentials:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
RAZORPAY_KEY_ID=rzp_test_your_key_id
SHOP_NAME=SoftTouch Towels & Linens
SHOP_PHONE=+91 98765 43210
SHOP_EMAIL=support@softtouchtowels.com
SHOP_ADDRESS=12, Handloom Street, Textile City, India
```

### Step 4: Make an Account the Admin
1. Sign up a new account in the app or via Supabase Auth (e.g. `admin@softtouchtowels.com`).
2. In Supabase **SQL Editor**, run:
```sql
UPDATE public.profiles
SET role = 'admin'
WHERE email = 'admin@softtouchtowels.com';
```
*(When this user logs in, they will automatically be routed to the **Admin Console** instead of the customer store!)*

### Step 5: Deploy Supabase Edge Functions
The project includes three Edge Functions inside `supabase/functions/`:
1. `create-razorpay-order`: Securely generates Razorpay order IDs.
2. `verify-razorpay-payment`: Cryptographically validates HMAC SHA-256 signatures and marks orders paid.
3. `notify-order-admin`: Dispatches FCM push notifications to admin devices on new orders or cancellations.

To deploy via Supabase CLI:
```bash
# Set Edge Function Secrets
supabase secrets set RAZORPAY_KEY_ID=rzp_test_xxxx
supabase secrets set RAZORPAY_KEY_SECRET=your_razorpay_secret_key
supabase secrets set FCM_SERVER_KEY=your_firebase_server_key

# Deploy Functions
supabase functions deploy create-razorpay-order
supabase functions deploy verify-razorpay-payment
supabase functions deploy notify-order-admin
```

### Step 6: Firebase Cloud Messaging (FCM) Setup
1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com).
2. Add an Android app with package name `com.towelshop.towel_shop`.
3. Download `google-services.json` and place it in `android/app/google-services.json`.
4. In Android build configuration, apply the Google Services Gradle plugin.

---

## 🧪 Testing the Complete App Flow (Step by Step)

### Step 1: Launch the Application
Run the app on an Android device or emulator:
```bash
flutter run
```
*Expected on screen*: The **SoftTouch Towels** login screen with warm textile branding.

### Step 2: 1-Tap Demo Testing
On the Login screen, two demo buttons are provided:
- **Tap "Customer"**: Logs in as customer `Kritik Khodiyar` and opens the Customer Store.
- **Tap "Admin Panel"**: Logs in as shop admin and opens the Admin Console.

### Step 3: Customer Flow
1. **Browse Towels**: Select categories (*Bath Towel, Hand Towel, Face Towel*), use the search bar.
2. **Product Details**: Tap any towel card to inspect GSM, cotton specifications, dimensions, and change quantity.
3. **Cart**: Tap "Add to Cart", then open the cart. Notice the real-time subtotal, shipping fee calculator (free shipping above ₹999), and item counters.
4. **Delivery Address**: Tap "Proceed to Checkout", add or select a delivery address (Flat, Street, Landmark, City, State, 6-digit Pincode).
5. **Payment**:
   - Choose **Cash on Delivery (COD)** and tap "Confirm COD Order".
   - Or choose **Online Payment (Razorpay)** to test online order verification.
6. **Order Receipt (PDF)**:
   - On the Order Success screen, tap **"Download / Share Invoice (PDF)"**.
   - An A4 tax invoice will render with shop header, order ID, items table, subtotal, and payment status.
7. **Order Tracking & Cancellation**:
   - Go to **Orders** from the bottom navigation.
   - Tap your order to view details.
   - Tap **"Cancel Order"** (active while status is Placed/Confirmed), enter a reason, and confirm. Notice the status updates to `Cancelled`.

### Step 4: Admin Console Flow
1. Tap **Profile** -> **"Toggle Role Demo"** (or log in with an admin account).
2. The **Admin Console** opens with:
   - Real-time indicator `Realtime Live Sync 🟢`.
   - KPI metrics: Total Orders, Pending Orders, Revenue.
   - Filterable list of orders (All, Placed, Confirmed, Shipped, Delivered, Cancelled).
3. **Order Fulfillment**:
   - Tap any order to view full customer details, phone, address, and items.
   - Tap `Confirmed` -> `Shipped` -> `Delivered` to advance order fulfillment.
   - For COD orders, tap **"Mark COD as Collected / Paid"**.
4. **Catalog Management**:
   - Switch to the **Towel Catalog** tab.
   - Tap the switch on any towel to toggle its visibility in the customer app.
   - Tap the Floating Action Button **"+ Add Towel"** to add a new towel with image upload.

---

## 🛡️ Static Analysis & Tests

Run static analysis:
```bash
flutter analyze
```
*(Result: 0 errors, 0 warnings, 0 linter issues)*

Run unit and widget tests:
```bash
flutter test
```
*(Result: All tests passed)*
