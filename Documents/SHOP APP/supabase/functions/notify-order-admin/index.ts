// Supabase Edge Function: notify-order-admin
// Sends FCM push notification to Admin device when a new order is placed or cancelled

// @ts-nocheck
declare const Deno: any;

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload = await req.json();
    // Payload can come from Supabase Webhook (record) or direct invocation
    const record = payload.record || payload;

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const fcmServerKey = Deno.env.get("FCM_SERVER_KEY"); // or service account token

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // Fetch all admin profiles that have an active FCM token
    const { data: admins, error: adminErr } = await supabaseAdmin
      .from("profiles")
      .select("id, fcm_token, name")
      .eq("role", "admin")
      .not("fcm_token", "is", null);

    if (adminErr || !admins || admins.length === 0) {
      return new Response(
        JSON.stringify({ message: "No admin tokens found to notify" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const isCancel = record.order_status === "Cancelled";
    const customerName = record.customer_name || "Customer";
    const totalAmount = record.total_amount ? `₹${record.total_amount}` : "";
    const paymentMethod = record.payment_method || "COD";
    const paymentStatus = record.payment_status || "unpaid";

    const title = isCancel
      ? `⚠️ Order Cancelled: #${record.order_number || record.id?.slice(0, 8)}`
      : `🛍️ New Order: ${customerName}`;

    const body = isCancel
      ? `Customer cancelled order ${record.order_number}. Reason: ${record.cancel_reason || "None"}`
      : `${customerName} placed order (${totalAmount}) – ${paymentMethod} (${paymentStatus})`;

    const results = [];

    if (fcmServerKey) {
      for (const admin of admins) {
        if (!admin.fcm_token) continue;
        try {
          const res = await fetch("https://fcm.googleapis.com/fcm/send", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `key=${fcmServerKey}`,
            },
            body: JSON.stringify({
              to: admin.fcm_token,
              notification: {
                title: title,
                body: body,
                sound: "default",
              },
              data: {
                order_id: record.id,
                order_number: record.order_number || "",
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                type: isCancel ? "order_cancelled" : "new_order",
              },
              priority: "high",
            }),
          });
          results.push(await res.json());
        } catch (e: any) {
          results.push({ error: e.message });
        }
      }
    }

    return new Response(
      JSON.stringify({ success: true, notified_admins: admins.length, results }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
