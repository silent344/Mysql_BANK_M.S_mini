class AppConstants {
  static const String appName = 'SoftTouch Towels';
  static const String appTagline = 'Pure Comfort & Luxury For Your Home';

  // Towel Categories
  static const List<String> categories = [
    'All',
    'Bath Towel',
    'Hand Towel',
    'Face Towel',
    'Beach Towel',
    'Bath Sheet',
    'Bath Robe',
  ];

  // Towel Materials
  static const List<String> materials = [
    '100% Aegean Turkish Cotton',
    '100% Egyptian Cotton',
    '100% Organic Combed Cotton',
    'Bamboo-Cotton Blend',
    'Textured Waffle Weave',
  ];

  // Towel Sizes
  static const List<String> commonSizes = [
    '30 x 30 cm (Face)',
    '50 x 90 cm (Hand)',
    '70 x 140 cm (Bath)',
    '90 x 180 cm (Beach)',
    '100 x 200 cm (Sheet)',
    'Free Size (Robe)',
  ];

  // Order Statuses
  static const String statusPlaced = 'Placed';
  static const String statusConfirmed = 'Confirmed';
  static const String statusShipped = 'Shipped';
  static const String statusDelivered = 'Delivered';
  static const String statusCancelled = 'Cancelled';

  static const List<String> orderStatuses = [
    statusPlaced,
    statusConfirmed,
    statusShipped,
    statusDelivered,
    statusCancelled,
  ];

  // Payment Methods
  static const String paymentMethodCOD = 'COD';
  static const String paymentMethodOnline = 'ONLINE';

  // Payment Statuses
  static const String paymentStatusUnpaid = 'unpaid';
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusRefunded = 'refunded';
  static const String paymentStatusFailed = 'failed';

  // Shipping
  static const double freeShippingThreshold = 999.0;
  static const double standardShippingFee = 60.0;
}
