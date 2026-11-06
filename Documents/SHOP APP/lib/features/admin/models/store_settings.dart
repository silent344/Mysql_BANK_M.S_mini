class StoreSettings {
  final String id;
  final String shopName;
  final String adminPhone;
  final bool isShopClosed;
  final String shopClosedNotice;
  final String adminSecurityPin;
  final DateTime? updatedAt;

  const StoreSettings({
    this.id = 'primary',
    this.shopName = 'SoftTouch Towels',
    this.adminPhone = '+91 98765 43210',
    this.isShopClosed = false,
    this.shopClosedNotice =
        'Shop is closed for some days so we cannot deliver your product right now.',
    this.adminSecurityPin = '8845',
    this.updatedAt,
  });

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    return StoreSettings(
      id: json['id'] as String? ?? 'primary',
      shopName: json['shop_name'] as String? ?? 'SoftTouch Towels',
      adminPhone: json['admin_phone'] as String? ?? '+91 98765 43210',
      isShopClosed: json['is_shop_closed'] as bool? ?? false,
      shopClosedNotice: json['shop_closed_notice'] as String? ??
          'Shop is closed for some days so we cannot deliver your product right now.',
      adminSecurityPin: json['admin_security_pin'] as String? ?? '8845',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'admin_phone': adminPhone,
      'is_shop_closed': isShopClosed,
      'shop_closed_notice': shopClosedNotice,
      'admin_security_pin': adminSecurityPin,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  StoreSettings copyWith({
    String? id,
    String? shopName,
    String? adminPhone,
    bool? isShopClosed,
    String? shopClosedNotice,
    String? adminSecurityPin,
    DateTime? updatedAt,
  }) {
    return StoreSettings(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      adminPhone: adminPhone ?? this.adminPhone,
      isShopClosed: isShopClosed ?? this.isShopClosed,
      shopClosedNotice: shopClosedNotice ?? this.shopClosedNotice,
      adminSecurityPin: adminSecurityPin ?? this.adminSecurityPin,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
