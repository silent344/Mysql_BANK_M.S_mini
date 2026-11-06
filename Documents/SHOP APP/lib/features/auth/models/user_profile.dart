class UserProfile {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role; // 'customer' or 'admin'
  final String? fcmToken;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.role = 'customer',
    this.fcmToken,
    this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      fcmToken: json['fcm_token'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'fcm_token': fcmToken,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
