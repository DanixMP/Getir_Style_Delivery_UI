class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    required this.role,
    this.fullName = '',
    this.city = '',
    this.email = '',
    this.vendorProfileId,
    this.vendorCategoryId,
    this.vendorBusinessName = '',
    this.vendorCity = '',
  });

  final String id;
  final String phone;
  final String role;
  final String fullName;
  final String city;
  final String email;

  // Vendor profile (present when role == 'vendor').
  final String? vendorProfileId;
  final String? vendorCategoryId;
  final String vendorBusinessName;
  final String vendorCity;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final p = profile is Map<String, dynamic> ? profile : const <String, dynamic>{};
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String? ?? 'customer',
      fullName: json['full_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      email: json['email'] as String? ?? '',
      vendorProfileId: p['id'] as String?,
      vendorCategoryId: p['category'] as String?,
      vendorBusinessName: p['business_name'] as String? ?? '',
      vendorCity: p['city'] as String? ?? '',
    );
  }
}
