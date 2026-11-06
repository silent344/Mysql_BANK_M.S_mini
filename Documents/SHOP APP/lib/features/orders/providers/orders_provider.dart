import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../address/models/address.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/order_model.dart';

// Sample demo orders for initial test preview
final List<OrderModel> _demoOrders = [
  OrderModel(
    id: 'ord-demo-1',
    orderNumber: 'TT-2026-8421',
    userId: 'demo-user',
    customerName: 'Kritik Khodiyar',
    customerPhone: '+91 98765 43210',
    addressSnapshot: {
      'name': 'Kritik Khodiyar',
      'phone': '9876543210',
      'line1': 'Flat 402, Lotus Residency',
      'line2': 'Ring Road, Near City Mall',
      'landmark': 'Opposite Central Park',
      'city': 'Surat',
      'state': 'Gujarat',
      'pincode': '395007',
    },
    totalAmount: 1448.00,
    subtotal: 1448.00,
    shippingFee: 0.0,
    paymentMethod: AppConstants.paymentMethodCOD,
    paymentStatus: AppConstants.paymentStatusUnpaid,
    orderStatus: AppConstants.statusPlaced,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    items: const [
      OrderItemModel(
        id: 'item-1',
        orderId: 'ord-demo-1',
        productName: 'Royal Turkish Plush Bath Towel',
        unitPrice: 799.00,
        quantity: 1,
        size: '70 x 140 cm',
        color: 'Linen Sand',
        totalPrice: 799.00,
      ),
      OrderItemModel(
        id: 'item-2',
        orderId: 'ord-demo-1',
        productName: 'Waffle Weave Quick-Dry Bath Towel',
        unitPrice: 649.00,
        quantity: 1,
        size: '75 x 150 cm',
        color: 'Sage Green',
        totalPrice: 649.00,
      ),
    ],
  ),
];

class OrdersState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final SupabaseService _supabaseService;
  final Ref _ref;
  RealtimeChannel? _realtimeChannel;

  OrdersNotifier(this._supabaseService, this._ref) : super(const OrdersState(isLoading: true)) {
    loadOrders();
    _subscribeToRealtime();
  }

  Future<void> loadOrders() async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;

    if (client != null && user != null && SupabaseService.isConfigured) {
      state = state.copyWith(isLoading: true);
      try {
        final data = await client
            .from('orders')
            .select('*, order_items(*)')
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        final items = (data as List)
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(orders: items, isLoading: false);
      } catch (e) {
        debugPrint('Error loading orders: $e');
        state = state.copyWith(orders: _demoOrders, isLoading: false);
      }
    } else {
      // Demo fallback
      state = state.copyWith(orders: _demoOrders, isLoading: false);
    }
  }

  void _subscribeToRealtime() {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;
    if (client == null || user == null || !SupabaseService.isConfigured) return;

    try {
      _realtimeChannel = client
          .channel('public:orders:user:${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: user.id,
            ),
            callback: (payload) {
              debugPrint('⚡ Customer order realtime update: ${payload.eventType}');
              loadOrders();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Realtime customer orders subscription error: $e');
    }
  }

  Future<OrderModel?> placeOrder({
    required Address address,
    required List<CartItem> items,
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required String paymentMethod,
    required String paymentStatus,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;

    final randomCode = (Random().nextInt(9000) + 1000).toString();
    final orderNumber = 'TT-${DateTime.now().year}-$randomCode';
    final orderId = const Uuid().v4();

    final orderSnapshot = {
      'id': orderId,
      'order_number': orderNumber,
      'user_id': user?.id,
      'customer_name': address.name,
      'customer_phone': address.phone,
      'address_snapshot': address.toJson(),
      'total_amount': totalAmount,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': AppConstants.statusPlaced,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'refund_status': 'none',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (client != null && user != null && SupabaseService.isConfigured) {
      try {
        // 1. Insert Order
        await client.from('orders').insert(orderSnapshot);

        // 2. Insert Order Items (with snapshot of product name and price)
        final orderItemsData = items.map((cartItem) {
          return {
            'order_id': orderId,
            'product_id': cartItem.productId,
            'product_name': cartItem.product.name,
            'product_image': cartItem.product.imageUrl,
            'unit_price': cartItem.product.price,
            'quantity': cartItem.quantity,
            'size': cartItem.selectedSize ?? cartItem.product.size,
            'color': cartItem.selectedColor ?? cartItem.product.color,
            'total_price': cartItem.totalPrice,
          };
        }).toList();

        await client.from('order_items').insert(orderItemsData);

        // 3. Clear Cart
        await _ref.read(cartProvider.notifier).clearCart();

        // 4. Trigger Admin notification Edge Function
        try {
          await client.functions.invoke('notify-order-admin', body: orderSnapshot);
        } catch (e) {
          debugPrint('Notify admin function trigger note: $e');
        }

        // 5. Fire high-priority Admin Notification on device
        NotificationService().showNewOrderAlert(
          orderNumber: orderNumber,
          customerName: address.name,
          totalAmount: totalAmount,
          paymentMethod: paymentMethod,
          orderId: orderId,
        );

        await loadOrders();

        final parsedItems = items.map((ci) => OrderItemModel(
              id: const Uuid().v4(),
              orderId: orderId,
              productId: ci.productId,
              productName: ci.product.name,
              productImage: ci.product.imageUrl,
              unitPrice: ci.product.price,
              quantity: ci.quantity,
              size: ci.selectedSize,
              color: ci.selectedColor,
              totalPrice: ci.totalPrice,
            )).toList();

        return OrderModel.fromJson(orderSnapshot).copyWith(items: parsedItems);
      } catch (e) {
        debugPrint('Error placing order in Supabase: $e');
        return null;
      }
    } else {
      // Demo Order Creation
      final orderItems = items.map((ci) => OrderItemModel(
            id: const Uuid().v4(),
            orderId: orderId,
            productId: ci.productId,
            productName: ci.product.name,
            productImage: ci.product.imageUrl,
            unitPrice: ci.product.price,
            quantity: ci.quantity,
            size: ci.selectedSize,
            color: ci.selectedColor,
            totalPrice: ci.totalPrice,
          )).toList();

      final newOrder = OrderModel(
        id: orderId,
        orderNumber: orderNumber,
        userId: 'demo-user',
        customerName: address.name,
        customerPhone: address.phone,
        addressSnapshot: address.toJson(),
        totalAmount: totalAmount,
        subtotal: subtotal,
        shippingFee: shippingFee,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        orderStatus: AppConstants.statusPlaced,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        createdAt: DateTime.now(),
        items: orderItems,
      );

      final updated = [newOrder, ...state.orders];
      state = state.copyWith(orders: updated);

      await _ref.read(cartProvider.notifier).clearCart();

      // Trigger admin order notification in demo mode
      NotificationService().showNewOrderAlert(
        orderNumber: orderNumber,
        customerName: address.name,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        orderId: orderId,
      );

      return newOrder;
    }
  }

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    final client = _supabaseService.client;
    final order = state.orders.firstWhere((o) => o.id == orderId);

    if (!order.isCancellable) return false;

    final refundStatus = order.isPaidOnline ? 'refund_pending' : 'none';

    if (client != null && SupabaseService.isConfigured) {
      try {
        await client.from('orders').update({
          'order_status': AppConstants.statusCancelled,
          'cancel_reason': reason,
          'refund_status': refundStatus,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId);

        // Notify admin about cancellation
        try {
          await client.functions.invoke('notify-order-admin', body: {
            'id': orderId,
            'order_number': order.orderNumber,
            'order_status': 'Cancelled',
            'cancel_reason': reason,
          });
        } catch (_) {}

        await loadOrders();
        return true;
      } catch (e) {
        debugPrint('Error cancelling order: $e');
        return false;
      }
    } else {
      final updated = state.orders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(
            orderStatus: AppConstants.statusCancelled,
            cancelReason: reason,
            refundStatus: refundStatus,
          );
        }
        return o;
      }).toList();
      state = state.copyWith(orders: updated);
      return true;
    }
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(SupabaseService(), ref);
});
