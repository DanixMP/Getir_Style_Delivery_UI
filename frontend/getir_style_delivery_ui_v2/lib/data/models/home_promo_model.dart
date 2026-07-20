import 'item_model.dart';

class HomeBannerModel {
  const HomeBannerModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.imageUrl,
    this.categorySlug,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? categorySlug;

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) => HomeBannerModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        imageUrl: (json['image'] as String?)?.trim().isNotEmpty == true
            ? json['image'] as String
            : null,
        categorySlug: (json['category_slug'] as String?)?.trim().isNotEmpty == true
            ? json['category_slug'] as String
            : null,
      );
}

class PromoItemModel {
  const PromoItemModel({
    required this.item,
    required this.effectivePrice,
    required this.originalPrice,
    this.badgeText = '',
  });

  final ItemModel item;
  final int effectivePrice;
  final int originalPrice;
  final String badgeText;

  bool get hasDiscount => effectivePrice < originalPrice;

  int? get discountPercent {
    if (!hasDiscount || originalPrice <= 0) return null;
    return ((1 - effectivePrice / originalPrice) * 100).round();
  }

  factory PromoItemModel.fromJson(Map<String, dynamic> json) {
    final itemJson = json['item'] as Map<String, dynamic>;
    return PromoItemModel(
      item: ItemModel.fromJson(itemJson),
      effectivePrice: (json['effective_price'] as num?)?.toInt() ??
          (json['sale_price'] as num?)?.toInt() ??
          (itemJson['price'] as num).toInt(),
      originalPrice: (json['original_price'] as num?)?.toInt() ??
          (itemJson['price'] as num).toInt(),
      badgeText: json['badge_text'] as String? ?? '',
    );
  }
}

class HomePromoModel {
  const HomePromoModel({
    this.banners = const [],
    this.discountedItems = const [],
    this.todaySpecials = const [],
  });

  final List<HomeBannerModel> banners;
  final List<PromoItemModel> discountedItems;
  final List<PromoItemModel> todaySpecials;

  bool get isEmpty =>
      banners.isEmpty && discountedItems.isEmpty && todaySpecials.isEmpty;

  factory HomePromoModel.fromJson(Map<String, dynamic> json) => HomePromoModel(
        banners: (json['banners'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(HomeBannerModel.fromJson)
            .toList(),
        discountedItems: (json['discounted_items'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PromoItemModel.fromJson)
            .toList(),
        todaySpecials: (json['today_specials'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PromoItemModel.fromJson)
            .toList(),
      );
}
