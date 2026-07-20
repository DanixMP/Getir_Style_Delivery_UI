import '../../core/network/api_parsing.dart';

class DiscountModel {
  const DiscountModel({
    required this.type,
    required this.discountPercent,
    required this.message,
    this.targetCategory,
  });

  final String type;
  final int discountPercent;
  final String message;
  final String? targetCategory;

  factory DiscountModel.fromJson(Map<String, dynamic> json) => DiscountModel(
        type: json['type'] as String? ?? '',
        discountPercent: parseInt(json['discount_percent']),
        message: json['message'] as String? ?? '',
        targetCategory: json['target_category'] as String?,
      );
}
