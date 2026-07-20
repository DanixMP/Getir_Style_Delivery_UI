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
        slug: json['slug'] as String,
        isComingSoon: json['is_coming_soon'] as bool? ?? false,
      );
}
