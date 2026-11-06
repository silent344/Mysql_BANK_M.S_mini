import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../products/models/product.dart';
import '../models/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get shippingFee {
    if (items.isEmpty) return 0.0;
    // Calculate total product delivery charges configured by admin
    final productDeliveryFee = items.fold(0.0, (sum, item) => sum + item.product.deliveryCharge);
    return productDeliveryFee;
  }

  double get totalAmount => subtotal + shippingFee;

  bool get qualifiesForFreeShipping => shippingFee == 0.0;

  double get freeShippingRemaining {
    if (qualifiesForFreeShipping || items.isEmpty) return 0.0;
    return AppConstants.freeShippingThreshold - subtotal;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final SupabaseService _supabaseService;

  CartNotifier(this._supabaseService) : super(const CartState()) {
    loadCart();
  }

  Future<void> loadCart() async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;

    if (client != null && user != null && SupabaseService.isConfigured) {
      state = state.copyWith(isLoading: true);
      try {
        final data = await client
            .from('cart_items')
            .select('id, quantity, product_id, products(*)')
            .eq('user_id', user.id);

        final loaded = <CartItem>[];
        for (final row in data as List) {
          final prodData = row['products'];
          if (prodData != null) {
            final prod = Product.fromJson(prodData as Map<String, dynamic>);
            loaded.add(CartItem(
              id: row['id'] as String,
              userId: user.id,
              productId: prod.id,
              quantity: (row['quantity'] as num?)?.toInt() ?? 1,
              product: prod,
            ));
          }
        }
        state = state.copyWith(items: loaded, isLoading: false);
      } catch (e) {
        debugPrint('Error loading cart from Supabase: $e');
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    final existingIndex = state.items.indexWhere((i) => i.productId == product.id);
    List<CartItem> updatedItems = List.from(state.items);

    if (existingIndex >= 0) {
      final existing = updatedItems[existingIndex];
      final newQty = (existing.quantity + quantity).clamp(1, product.stock);
      updatedItems[existingIndex] = existing.copyWith(quantity: newQty);
    } else {
      updatedItems.add(CartItem(
        id: 'cart-${DateTime.now().millisecondsSinceEpoch}',
        userId: _supabaseService.currentUser?.id ?? 'guest',
        productId: product.id,
        quantity: quantity.clamp(1, product.stock),
        product: product,
        selectedSize: size ?? product.size,
        selectedColor: color ?? product.color,
      ));
    }

    state = state.copyWith(items: updatedItems);
    await _syncToSupabase(product.id, existingIndex >= 0 ? updatedItems[existingIndex].quantity : quantity);
  }

  Future<void> incrementQuantity(String productId) async {
    final index = state.items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      final item = state.items[index];
      if (item.quantity < item.product.stock) {
        final newQty = item.quantity + 1;
        final updated = List<CartItem>.from(state.items);
        updated[index] = item.copyWith(quantity: newQty);
        state = state.copyWith(items: updated);
        await _syncToSupabase(productId, newQty);
      }
    }
  }

  Future<void> decrementQuantity(String productId) async {
    final index = state.items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      final item = state.items[index];
      if (item.quantity > 1) {
        final newQty = item.quantity - 1;
        final updated = List<CartItem>.from(state.items);
        updated[index] = item.copyWith(quantity: newQty);
        state = state.copyWith(items: updated);
        await _syncToSupabase(productId, newQty);
      } else {
        await removeFromCart(productId);
      }
    }
  }

  Future<void> removeFromCart(String productId) async {
    final updated = state.items.where((i) => i.productId != productId).toList();
    state = state.copyWith(items: updated);

    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;
    if (client != null && user != null && SupabaseService.isConfigured) {
      try {
        await client
            .from('cart_items')
            .delete()
            .match({'user_id': user.id, 'product_id': productId});
      } catch (e) {
        debugPrint('Error deleting from cart in Supabase: $e');
      }
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(items: []);

    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;
    if (client != null && user != null && SupabaseService.isConfigured) {
      try {
        await client.from('cart_items').delete().eq('user_id', user.id);
      } catch (e) {
        debugPrint('Error clearing cart in Supabase: $e');
      }
    }
  }

  Future<void> _syncToSupabase(String productId, int quantity) async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;
    if (client != null && user != null && SupabaseService.isConfigured) {
      try {
        await client.from('cart_items').upsert({
          'user_id': user.id,
          'product_id': productId,
          'quantity': quantity,
        });
      } catch (e) {
        debugPrint('Error syncing cart to Supabase: $e');
      }
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(SupabaseService());
});
