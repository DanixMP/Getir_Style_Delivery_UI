class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    required this.role,
    this.fullName = '',
    this.city = '',
    this.email = '',
  });

  final String id;
  final String phone;
  final String role;
  final String fullName;
  final String city;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phone: json['phone'] as String,
        role: json['role'] as String? ?? 'customer',
        fullName: json['full_name'] as String? ?? '',
        city: json['city'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}
