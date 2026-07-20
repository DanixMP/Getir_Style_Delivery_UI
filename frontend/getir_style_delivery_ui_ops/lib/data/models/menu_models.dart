import '../../core/network/api_parsing.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.isComingSoon = false,
  });

  final String id;
  final String name;
  final String slug;
  final bool isComingSoon;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String? ?? '',
        isComingSoon: json['is_coming_soon'] as bool? ?? false,
      );
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
    this.categoryId,
    this.categorySlug = '',
    this.description = '',
  });

  final String id;
  final String name;
  final int price;
  final bool isAvailable;
  final String? categoryId;
  final String categorySlug;
  final String description;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        price: parseInt(json['price']),
        isAvailable: json['is_available'] as bool? ?? true,
        categoryId: json['category'] as String?,
        categorySlug: json['category_slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}
