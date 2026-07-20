import 'dining_table_model.dart';
import 'item_model.dart';
import 'vendor_model.dart';
import 'venue_panorama_model.dart';

class DineInVenueModel {
  const DineInVenueModel({
    required this.vendor,
    this.panorama,
    this.tables = const [],
    this.featuredItems = const [],
  });

  final VendorModel vendor;
  final VenuePanoramaModel? panorama;
  final List<DiningTableModel> tables;
  final List<ItemModel> featuredItems;

  factory DineInVenueModel.fromJson(Map<String, dynamic> json) {
    final panoramaRaw = json['panorama'];
    return DineInVenueModel(
      vendor: VendorModel.fromJson(json['vendor'] as Map<String, dynamic>),
      panorama: panoramaRaw is Map<String, dynamic>
          ? VenuePanoramaModel.fromJson(panoramaRaw)
          : null,
      tables: (json['tables'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DiningTableModel.fromJson)
          .toList(),
      featuredItems: (json['featured_items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ItemModel.fromJson)
          .toList(),
    );
  }
}