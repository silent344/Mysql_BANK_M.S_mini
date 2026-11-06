import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../orders/models/order_model.dart';
import '../../orders/providers/orders_provider.dart';
import '../../products/models/product.dart';
import '../../products/providers/products_provider.dart';

class AdminState {
  final List<OrderModel> orders;
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String statusFilter; // 'All', 'Placed', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'
  final String paymentFilter; // 'All', 'COD', 'ONLINE'

  const AdminState({
    this.orders = const [],
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.statusFilter = 'All',
    this.paymentFilter = 'All',
  });

  List<OrderModel> get filteredOrders {
    return orders.where((order) {
      final matchesStatus = statusFilter == 'All' || order.orderStatus == statusFilter;
      final matchesPayment = paymentFilter == 'All' || order.paymentMethod == paymentFilter;
      return matchesStatus && matchesPayment;
    }).toList();
  }

  int get totalOrdersCount => orders.length;
  int get pendingOrdersCount => orders
      .where((o) => o.orderStatus == AppConstants.statusPlaced || o.orderStatus == AppConstants.statusConfirmed)
      .length;
  double get totalRevenue => orders
      .where((o) => o.paymentStatus == AppConstants.paymentStatusPaid)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  AdminState copyWith({
    List<OrderModel>? orders,
    List<Product>? products,
    bool? isLoading,
    String? error,
    String? statusFilter,
    String? paymentFilter,
    bool clearError = false,
  }) {
    return AdminState(
      orders: orders ?? this.orders,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statusFilter: statusFilter ?? this.statusFilter,
      paymentFilter: paymentFilter ?? this.paymentFilter,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final SupabaseService _supabaseService;
  final Ref _ref;
  RealtimeChannel? _ordersChannel;
  RealtimeChannel? _productsChannel;

  AdminNotifier(this._supabaseService, this._ref) : super(const AdminState(isLoading: true)) {
    loadAllData();
    _subscribeToRealtime();
  }

  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.wait([
      loadAllOrders(),
      loadAllProducts(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> loadAllOrders() async {
    final client = _supabaseService.client;
    if (client != null && SupabaseService.isConfigured) {
      try {
        final data = await client
            .from('orders')
            .select('*, order_items(*)')
            .order('created_at', ascending: false);

        final items = (data as List)
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(orders: items);
      } catch (e) {
        debugPrint('Admin orders fetch error: $e');
      }
    } else {
      state = state.copyWith(orders: _ref.read(ordersProvider).orders);
    }
  }

  Future<void> loadAllProducts() async {
    final client = _supabaseService.client;
    if (client != null && SupabaseService.isConfigured) {
      try {
        final data = await client
            .from('products')
            .select()
            .order('created_at', ascending: false);

        final items = (data as List)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(products: items);
      } catch (e) {
        debugPrint('Admin products fetch error: $e');
      }
    } else {
      // Connect to productsProvider list
      var prods = _ref.read(productsProvider).products;
      if (prods.isEmpty) {
        await _ref.read(productsProvider.notifier).loadProducts();
        prods = _ref.read(productsProvider).products;
      }
      state = state.copyWith(products: prods);
    }
  }

  void _subscribeToRealtime() {
    final client = _supabaseService.client;
    if (client == null || !SupabaseService.isConfigured) return;

    try {
      // Subscribe to all changes in orders table
      _ordersChannel = client
          .channel('admin:orders')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            callback: (payload) {
              debugPrint('⚡ Admin Realtime Order Event: ${payload.eventType}');
              final record = payload.newRecord;

              if (payload.eventType == PostgresChangeEvent.insert) {
                // New Order Placed
                final customer = record['customer_name'] ?? 'Customer';
                final method = record['payment_method'] ?? 'COD';
                final amount = double.tryParse(record['total_amount']?.toString() ?? '0') ?? 0.0;
                final orderNum = record['order_number'] ?? (record['id'] != null ? record['id'].toString().substring(0, 8) : '');

                NotificationService().showNewOrderAlert(
                  orderNumber: orderNum,
                  customerName: customer,
                  totalAmount: amount,
                  paymentMethod: method,
                  orderId: record['id'] as String?,
                );
              } else if (payload.eventType == PostgresChangeEvent.update) {
                if (record['order_status'] == AppConstants.statusCancelled) {
                  NotificationService().showNotification(
                    title: '⚠️ Order Cancelled: #${record['order_number'] ?? ''}',
                    body: 'Reason: ${record['cancel_reason'] ?? 'Customer requested cancellation'}',
                    payload: record['id'] as String?,
                  );
                }
              }

              loadAllOrders();
            },
          )
          .subscribe();

      // Subscribe to product table changes
      _productsChannel = client
          .channel('admin:products')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'products',
            callback: (_) {
              loadAllProducts();
              _ref.read(productsProvider.notifier).loadProducts();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Admin Realtime subscription setup error: $e');
    }
  }

  void setStatusFilter(String filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setPaymentFilter(String filter) {
    state = state.copyWith(paymentFilter: filter);
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    final client = _supabaseService.client;
    if (client != null && SupabaseService.isConfigured) {
      try {
        await client.from('orders').update({
          'order_status': newStatus,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId);

        await loadAllOrders();
        return true;
      } catch (e) {
        debugPrint('Admin update order status error: $e');
        return false;
      }
    } else {
      final updated = state.orders.map((o) {
        if (o.id == orderId) return o.copyWith(orderStatus: newStatus);
        return o;
      }).toList();
      state = state.copyWith(orders: updated);
      return true;
    }
  }

  Future<bool> markCodOrderPaid(String orderId) async {
    final client = _supabaseService.client;
    if (client != null && SupabaseService.isConfigured) {
      try {
        await client.from('orders').update({
          'payment_status': AppConstants.paymentStatusPaid,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId);

        await loadAllOrders();
        return true;
      } catch (e) {
        debugPrint('Admin mark COD paid error: $e');
        return false;
      }
    } else {
      final updated = state.orders.map((o) {
        if (o.id == orderId) return o.copyWith(paymentStatus: AppConstants.paymentStatusPaid);
        return o;
      }).toList();
      state = state.copyWith(orders: updated);
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // PRODUCTS CRUD
  // ---------------------------------------------------------------------------

  Future<String?> uploadProductImage(Uint8List bytes, String filename) async {
    final client = _supabaseService.client;
    if (client != null && SupabaseService.isConfigured) {
      try {
        final ext = filename.split('.').last;
        final storagePath = 'product_${const Uuid().v4()}.$ext';

        await client.storage.from('products').uploadBinary(
              storagePath,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
            );

        return client.storage.from('products').getPublicUrl(storagePath);
      } catch (e) {
        debugPrint('Storage upload error: $e');
        return null;
      }
    }
    return null;
  }

  Future<bool> addProduct(Product product, {Uint8List? imageBytes, String? filename}) async {
    final client = _supabaseService.client;
    var finalImageUrl = product.imageUrl;

    if (imageBytes != null && filename != null) {
      final uploadedUrl = await uploadProductImage(imageBytes, filename);
      if (uploadedUrl != null) finalImageUrl = uploadedUrl;
    }

    final newProduct = product.copyWith(
      id: const Uuid().v4(),
      imageUrl: finalImageUrl,
    );

    if (client != null && SupabaseService.isConfigured) {
      try {
        final data = newProduct.toJson();
        await client.from('products').insert(data);
        await loadAllProducts();
        _ref.read(productsProvider.notifier).loadProducts();
        return true;
      } catch (e) {
        debugPrint('Error inserting product in Supabase: $e');
        state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
        return false;
      }
    } else {
      final updated = [newProduct, ...state.products];
      state = state.copyWith(products: updated);
      _ref.read(productsProvider.notifier).loadProducts();
      return true;
    }
  }

  Future<bool> updateProduct(Product product, {Uint8List? imageBytes, String? filename}) async {
    final client = _supabaseService.client;
    var finalImageUrl = product.imageUrl;

    if (imageBytes != null && filename != null) {
      final uploadedUrl = await uploadProductImage(imageBytes, filename);
      if (uploadedUrl != null) finalImageUrl = uploadedUrl;
    }

    final updatedProduct = product.copyWith(imageUrl: finalImageUrl);

    if (client != null && SupabaseService.isConfigured) {
      try {
        await client
            .from('products')
            .update(updatedProduct.toJson())
            .eq('id', updatedProduct.id);

        await loadAllProducts();
        _ref.read(productsProvider.notifier).loadProducts();
        return true;
      } catch (e) {
        debugPrint('Error updating product in Supabase: $e');
        state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
        return false;
      }
    } else {
      final updated = state.products.map((p) {
        if (p.id == updatedProduct.id) return updatedProduct;
        return p;
      }).toList();
      state = state.copyWith(products: updated);
      _ref.read(productsProvider.notifier).loadProducts();
      return true;
    }
  }

  Future<bool> toggleProductActive(String productId, bool isActive) async {
    final client = _supabaseService.client;
    if (client != null && SupabaseService.isConfigured) {
      try {
        await client
            .from('products')
            .update({'is_active': isActive})
            .eq('id', productId);
        await loadAllProducts();
        _ref.read(productsProvider.notifier).loadProducts();
        return true;
      } catch (e) {
        debugPrint('Error toggling product status: $e');
        state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
        return false;
      }
    } else {
      final updated = state.products.map((p) {
        if (p.id == productId) return p.copyWith(isActive: isActive);
        return p;
      }).toList();
      state = state.copyWith(products: updated);
      _ref.read(productsProvider.notifier).loadProducts();
      return true;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    final client = _supabaseService.client;
    if (client != null && SupabaseService.isConfigured) {
      try {
        await client.from('products').delete().eq('id', productId);
        await loadAllProducts();
        _ref.read(productsProvider.notifier).loadProducts();
        return true;
      } catch (e) {
        debugPrint('Error deleting product: $e');
        state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
        return false;
      }
    } else {
      final updated = state.products.where((p) => p.id != productId).toList();
      state = state.copyWith(products: updated);
      _ref.read(productsProvider.notifier).loadProducts();
      return true;
    }
  }

  @override
  void dispose() {
    _ordersChannel?.unsubscribe();
    _productsChannel?.unsubscribe();
    super.dispose();
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(SupabaseService(), ref);
});
