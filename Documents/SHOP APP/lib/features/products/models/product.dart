class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int stock;
  final String category;
  final String imageUrl;
  final List<String> additionalImages;
  final String? color;
  final String? size;
  final String material;
  final int gsm;
  final bool isActive;
  final double deliveryCharge;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.originalPrice,
    required this.stock,
    required this.category,
    required this.imageUrl,
    this.additionalImages = const [],
    this.color,
    this.size,
    this.material = '100% Turkish Cotton',
    this.gsm = 550,
    this.isActive = true,
    this.deliveryCharge = 0.0,
    this.createdAt,
  });

  bool get isInStock => stock > 0;
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  bool get hasFreeDelivery => deliveryCharge <= 0;
  String get deliveryText => hasFreeDelivery ? 'FREE Delivery' : '₹${deliveryCharge.toInt()} Delivery';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Towel',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? 'Bath Towel',
      imageUrl: json['image_url'] as String? ??
          'https://images.unsplash.com/photo-1616627547584-bf28cee262db?auto=format&fit=crop&w=800&q=80',
      additionalImages: (json['additional_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      color: json['color'] as String?,
      size: json['size'] as String?,
      material: json['material'] as String? ?? '100% Turkish Cotton',
      gsm: (json['gsm'] as num?)?.toInt() ?? 550,
      isActive: json['is_active'] as bool? ?? true,
      deliveryCharge: (json['delivery_charge'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
      'additional_images': additionalImages,
      'color': color,
      'size': size,
      'material': material,
      'gsm': gsm,
      'is_active': isActive,
      'delivery_charge': deliveryCharge,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? stock,
    String? category,
    String? imageUrl,
    List<String>? additionalImages,
    String? color,
    String? size,
    String? material,
    int? gsm,
    bool? isActive,
    double? deliveryCharge,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalImages: additionalImages ?? this.additionalImages,
      color: color ?? this.color,
      size: size ?? this.size,
      material: material ?? this.material,
      gsm: gsm ?? this.gsm,
      isActive: isActive ?? this.isActive,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
