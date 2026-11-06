import '../../products/models/product.dart';

class CartItem {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final Product product;
  final String? selectedSize;
  final String? selectedColor;

  const CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    this.quantity = 1,
    required this.product,
    this.selectedSize,
    this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    Product? product,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    };
  }
}
