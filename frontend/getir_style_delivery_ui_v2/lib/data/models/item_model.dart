import '../../core/assets/catalog_images.dart';
import '../../core/network/api_parsing.dart';

class ItemModel {
  const ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.vendorName,
    required this.categorySlug,
    this.vendorId,
    this.description = '',
    this.rating = 0,
    this.city = '',
    this.imageUrl,
  });

  final String id;
  final String name;
  final int price;
  final String vendorName;
  final String categorySlug;
  final String? vendorId;
  final String description;
  final double rating;
  final String city;
  final String? imageUrl;

  String get displayImageUrl => CatalogImages.forItem(
        existingUrl: imageUrl,
        name: name,
        categorySlug: categorySlug,
      );

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    String? image;
    final gallery = json['gallery'];
    if (gallery is List && gallery.isNotEmpty) {
      final first = gallery.first;
      if (first is Map<String, dynamic>) {
        image = mediaUrl(first['image'] as String?);
      }
    }
    return ItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: parseInt(json['price']),
      vendorName: json['vendor_name'] as String? ?? '',
      categorySlug: json['category_slug'] as String? ?? '',
      vendorId: json['vendor'] as String?,
      description: json['description'] as String? ?? '',
      rating: parseDouble(json['rating']),
      city: json['city'] as String? ?? '',
      imageUrl: image,
    );
  }
}
