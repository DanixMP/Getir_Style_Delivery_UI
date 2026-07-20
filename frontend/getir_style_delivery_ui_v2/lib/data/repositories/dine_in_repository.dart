import '../../core/network/api_client.dart';
import '../../core/network/api_parsing.dart';
import '../models/dine_in_venue_model.dart';
import '../models/vendor_model.dart';

class DineInRepository {
  DineInRepository(this._client);

  final ApiClient _client;

  /// Restaurants in the dine-in category that support table booking.
  Future<List<VendorModel>> getDineInRestaurants({String? city}) async {
    final resp = await _client.dio.get(
      '/catalog/vendors/',
      queryParameters: {
        'category': 'getir_style_delivery_ui-restaurant',
        'supports_dine_in': true,
        if (city != null) 'city': city,
      },
    );
    return parseList(resp.data, VendorModel.fromJson);
  }

  /// Panorama, tables, and vendor summary for a dine-in venue.
  Future<DineInVenueModel> getVenueDetail(String vendorId) async {
    final resp = await _client.dio.get('/catalog/vendors/$vendorId/dine-in/');
    return DineInVenueModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Reserve a table briefly while the customer completes checkout.
  Future<void> holdTable({
    required String vendorId,
    required String tableId,
  }) async {
    await _client.dio.post(
      '/catalog/vendors/$vendorId/tables/$tableId/hold/',
    );
  }
}
