import '../../../core/constants/app_constants.dart';

class OrderItemModel {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final String? productImage;
  final double unitPrice;
  final int quantity;
  final String? size;
  final String? color;
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.productImage,
    required this.unitPrice,
    required this.quantity,
    this.size,
    this.color,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String? ?? 'Towel',
      productImage: json['product_image'] as String?,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      size: json['size'] as String?,
      color: json['color'] as String?,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'unit_price': unitPrice,
      'quantity': quantity,
      'size': size,
      'color': color,
      'total_price': totalPrice,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String? userId;
  final String customerName;
  final String customerPhone;
  final Map<String, dynamic> addressSnapshot;
  final double totalAmount;
  final double subtotal;
  final double shippingFee;
  final String paymentMethod; // 'COD' or 'ONLINE'
  final String paymentStatus; // 'unpaid', 'paid', 'refunded', 'failed'
  final String orderStatus; // 'Placed', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? cancelReason;
  final String refundStatus; // 'none', 'refund_pending', 'refunded'
  final String? notes;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.addressSnapshot,
    required this.totalAmount,
    required this.subtotal,
    this.shippingFee = 0.0,
    required this.paymentMethod,
    this.paymentStatus = AppConstants.paymentStatusUnpaid,
    this.orderStatus = AppConstants.statusPlaced,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.cancelReason,
    this.refundStatus = 'none',
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  bool get isCancellable =>
      orderStatus == AppConstants.statusPlaced || orderStatus == AppConstants.statusConfirmed;

  bool get isPaidOnline =>
      paymentMethod == AppConstants.paymentMethodOnline &&
      paymentStatus == AppConstants.paymentStatusPaid;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['order_items'];
    List<OrderItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? 'ORD-${json['id']?.toString().substring(0, 6)}',
      userId: json['user_id'] as String?,
      customerName: json['customer_name'] as String? ?? 'Customer',
      customerPhone: json['customer_phone'] as String? ?? '',
      addressSnapshot: json['address_snapshot'] is Map
          ? Map<String, dynamic>.from(json['address_snapshot'] as Map)
          : {},
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? AppConstants.paymentMethodCOD,
      paymentStatus: json['payment_status'] as String? ?? AppConstants.paymentStatusUnpaid,
      orderStatus: json['order_status'] as String? ?? AppConstants.statusPlaced,
      razorpayOrderId: json['razorpay_order_id'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      razorpaySignature: json['razorpay_signature'] as String?,
      cancelReason: json['cancel_reason'] as String?,
      refundStatus: json['refund_status'] as String? ?? 'none',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
      items: parsedItems,
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? customerName,
    String? customerPhone,
    Map<String, dynamic>? addressSnapshot,
    double? totalAmount,
    double? subtotal,
    double? shippingFee,
    String? paymentMethod,
    String? paymentStatus,
    String? orderStatus,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
    String? cancelReason,
    String? refundStatus,
    String? notes,
    DateTime? createdAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      addressSnapshot: addressSnapshot ?? this.addressSnapshot,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      cancelReason: cancelReason ?? this.cancelReason,
      refundStatus: refundStatus ?? this.refundStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
