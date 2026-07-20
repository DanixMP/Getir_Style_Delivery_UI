import '../../core/network/api_parsing.dart';

class VendorModel {
  const VendorModel({
    required this.id,
    required this.businessName,
    required this.city,
    this.categoryId,
    this.rating = 0,
    this.description = '',
    this.logoUrl,
    this.coverImageUrl,
    this.address = '',
    this.ratingCount = 0,
    this.supportsDineIn = false,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String businessName;
  final String city;
  final String? categoryId;
  final double rating;
  final String description;
  final String? logoUrl;
  final String? coverImageUrl;
  final String address;
  final int ratingCount;
  final bool supportsDineIn;
  final double? latitude;
  final double? longitude;

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
        id: json['id'] as String,
        businessName: json['business_name'] as String,
        city: json['city'] as String? ?? '',
        categoryId: json['category'] as String?,
        rating: parseDouble(json['rating']),
        description: json['description'] as String? ?? '',
        logoUrl: mediaUrl(json['logo'] as String?),
        coverImageUrl: mediaUrl(json['cover_image_url'] as String?),
        address: json['address'] as String? ?? '',
        ratingCount: json['rating_count'] is int
            ? json['rating_count'] as int
            : int.tryParse('${json['rating_count']}') ?? 0,
        supportsDineIn: json['supports_dine_in'] as bool? ?? false,
        latitude: _optionalCoord(json['latitude']),
        longitude: _optionalCoord(json['longitude']),
      );
}

double? _optionalCoord(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
