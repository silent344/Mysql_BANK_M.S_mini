class Address {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String line1; // House / Flat / Floor / Building
  final String line2; // Street / Area / Locality
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;
  final DateTime? createdAt;

  const Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.line1,
    required this.line2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
    this.createdAt,
  });

  String get formattedAddress {
    final landmarkPart = landmark != null && landmark!.isNotEmpty ? ', near $landmark' : '';
    return '$line1, $line2$landmarkPart, $city, $state - $pincode';
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String? ?? '',
      landmark: json['landmark'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? line1,
    String? line2,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
