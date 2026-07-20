import '../../core/network/api_parsing.dart';

class PeykModel {
  const PeykModel({
    required this.id,
    required this.userId,
    required this.peykCode,
    required this.fullName,
    required this.isAvailable,
    required this.vehicleType,
    required this.rating,
  });

  final String id; // PeykProfile id (for availability/call endpoints)
  final String userId; // CustomUser id (needed to assign)
  final String peykCode;
  final String fullName;
  final bool isAvailable;
  final String vehicleType;
  final double rating;

  factory PeykModel.fromJson(Map<String, dynamic> json) => PeykModel(
        id: json['id'] as String,
        userId: json['user_id'] as String? ?? '',
        peykCode: json['peyk_code'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        isAvailable: json['is_available'] as bool? ?? false,
        vehicleType: json['vehicle_type'] as String? ?? '',
        rating: parseDouble(json['rating']),
      );
}

/// A vendor row from the operator checklist, with its items.
class VendorChecklistModel {
  const VendorChecklistModel({
    required this.vendorId,
    required this.businessName,
    required this.items,
  });

  final String vendorId;
  final String businessName;
  final List<ChecklistItem> items;

  factory VendorChecklistModel.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = raw is List
        ? raw.whereType<Map<String, dynamic>>().map(ChecklistItem.fromJson).toList()
        : <ChecklistItem>[];
    return VendorChecklistModel(
      vendorId: json['vendor_id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      items: items,
    );
  }
}

class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final int price;
  final bool isAvailable;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        price: parseInt(json['price']),
        isAvailable: json['is_available'] as bool? ?? true,
      );
}
