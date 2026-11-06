import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/product.dart';

// Sample fallback seed products for preview & demo
final List<Product> _demoProducts = [
  const Product(
    id: 'prod-1',
    name: 'Royal Turkish Plush Bath Towel',
    description:
        'Crafted from 100% long-staple Aegean Turkish cotton, this 700 GSM bath towel offers ultra-absorbency, cloud-like softness, and rapid drying. Finished with a double-stitched hem for enduring luxury.',
    price: 799.00,
    originalPrice: 1299.00,
    stock: 45,
    category: 'Bath Towel',
    imageUrl:
        'https://images.unsplash.com/photo-1616627547584-bf28cee262db?auto=format&fit=crop&w=800&q=80',
    color: 'Linen Sand',
    size: '70 x 140 cm',
    material: '100% Aegean Turkish Cotton',
    gsm: 700,
    isActive: true,
  ),
  const Product(
    id: 'prod-2',
    name: 'Waffle Weave Quick-Dry Bath Towel',
    description:
        'Modern textured waffle weave that gently exfoliates while absorbing water in seconds. Exceptionally lightweight, compact, and naturally antimicrobial.',
    price: 649.00,
    originalPrice: 999.00,
    stock: 38,
    category: 'Bath Towel',
    imageUrl:
        'https://images.unsplash.com/photo-1583845112203-29329902332e?auto=format&fit=crop&w=800&q=80',
    color: 'Sage Green',
    size: '75 x 150 cm',
    material: '100% Organic Cotton',
    gsm: 450,
    isActive: true,
  ),
  const Product(
    id: 'prod-3',
    name: 'Organic Cotton Hand Towel (Set of 2)',
    description:
        'Elevate your guest bathroom or daily routine. Soft zero-twist cotton loops provide gentle, fast water absorption and retain fluffiness wash after wash.',
    price: 499.00,
    originalPrice: 799.00,
    stock: 60,
    category: 'Hand Towel',
    imageUrl:
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80',
    color: 'Eucalyptus Green',
    size: '50 x 90 cm',
    material: '100% Combed Cotton',
    gsm: 550,
    isActive: true,
  ),
  const Product(
    id: 'prod-4',
    name: 'Ultra-Soft Bamboo Face Towels (Pack of 4)',
    description:
        'Naturally hypoallergenic and anti-bacterial bamboo-cotton blend. Gentle on sensitive skin and ideal for makeup removal, cleansing, and infant care.',
    price: 399.00,
    originalPrice: 599.00,
    stock: 85,
    category: 'Face Towel',
    imageUrl:
        'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?auto=format&fit=crop&w=800&q=80',
    color: 'Pure Ivory',
    size: '30 x 30 cm',
    material: '70% Bamboo / 30% Cotton',
    gsm: 600,
    isActive: true,
  ),
  const Product(
    id: 'prod-5',
    name: 'Cabana Striped Oversized Beach Towel',
    description:
        'Classic nautical stripe design in vibrant sun-resistant dyes. Generously oversized with a velour front for lounging and a terry loop back for drying.',
    price: 999.00,
    originalPrice: 1499.00,
    stock: 25,
    category: 'Beach Towel',
    imageUrl:
        'https://images.unsplash.com/photo-1507652313519-d4e9174996dd?auto=format&fit=crop&w=800&q=80',
    color: 'Navy & Terracotta',
    size: '90 x 180 cm',
    material: '100% Ring Spun Cotton',
    gsm: 500,
    isActive: true,
  ),
  const Product(
    id: 'prod-6',
    name: 'Hotel Grandeur Bath Sheet',
    description:
        'Extra-large spa bath sheet for total full-body wrapping. Luxuriously heavy and ultra-absorbent, making every bath feel like a 5-star resort experience.',
    price: 1199.00,
    originalPrice: 1899.00,
    stock: 20,
    category: 'Bath Sheet',
    imageUrl:
        'https://images.unsplash.com/photo-1520699049698-acd2fccb8cc8?auto=format&fit=crop&w=800&q=80',
    color: 'Warm Charcoal',
    size: '100 x 200 cm',
    material: '100% Egyptian Cotton',
    gsm: 800,
    isActive: true,
  ),
  const Product(
    id: 'prod-7',
    name: 'Kimono Collar Cotton Waffle Bathrobe',
    description:
        'Lightweight, breathable, and deeply absorbent. Features dual pockets, a tailored kimono collar, and an adjustable waist tie for effortless lounging.',
    price: 1899.00,
    originalPrice: 2799.00,
    stock: 15,
    category: 'Bath Robe',
    imageUrl:
        'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80',
    color: 'Sand Beige',
    size: 'Free Size',
    material: '100% Ring Spun Cotton',
    gsm: 400,
    isActive: true,
  ),
];

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String selectedCategory;
  final String searchQuery;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  List<Product> get filteredProducts {
    return products.where((p) {
      if (!p.isActive) return false;
      final matchesCategory =
          selectedCategory == 'All' || p.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesQuery = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? searchQuery,
    bool clearError = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final SupabaseService _supabaseService;
  RealtimeChannel? _realtimeChannel;

  ProductsNotifier(this._supabaseService) : super(const ProductsState(isLoading: true)) {
    loadProducts();
    _subscribeToRealtime();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
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

        state = state.copyWith(
          products: items.isEmpty ? _demoProducts : items,
          isLoading: false,
        );
      } catch (e) {
        debugPrint('Error loading products from Supabase: $e');
        state = state.copyWith(
          products: _demoProducts,
          isLoading: false,
        );
      }
    } else {
      // Demo fallback
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(
        products: _demoProducts,
        isLoading: false,
      );
    }
  }

  void _subscribeToRealtime() {
    final client = _supabaseService.client;
    if (client == null || !SupabaseService.isConfigured) return;

    try {
      _realtimeChannel = client
          .channel('public:products')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'products',
            callback: (payload) {
              debugPrint('⚡ Realtime Product update received: ${payload.eventType}');
              loadProducts();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Realtime products subscription error: $e');
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier(SupabaseService());
});
