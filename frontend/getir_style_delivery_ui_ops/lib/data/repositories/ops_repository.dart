import '../../core/network/api_client.dart';
import '../../core/network/api_parsing.dart';
import '../models/menu_models.dart';
import '../models/order_model.dart';
import '../models/peyk_model.dart';

/// Operator + vendor actions, all on existing backend endpoints.
class OpsRepository {
  OpsRepository(this._client);

  final ApiClient _client;

  // ── Orders (operator sees all; vendor sees own — backend scopes by role) ──
  Future<List<OrderModel>> getOrders() async {
    final resp = await _client.dio.get('/orders/');
    return parseList(resp.data, OrderModel.fromJson);
  }

  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final resp = await _client.dio.patch(
      '/orders/$id/status/',
      data: {'status': status},
    );
    return OrderModel.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── Peyk board (operator) ──
  Future<List<PeykModel>> getPeyks() async {
    final resp = await _client.dio.get('/operator/peyks/');
    return parseList(resp.data, PeykModel.fromJson);
  }

  Future<void> setPeykAvailability(String peykProfileId, bool available) async {
    await _client.dio.patch(
      '/operator/peyks/$peykProfileId/availability/',
      data: {'is_available': available},
    );
  }

  /// Operator → peyk call (LiveKit token; needs the server's LiveKit running).
  /// The peyk call endpoint keys on the peyk's CustomUser id.
  Future<Map<String, dynamic>> callPeyk(String peykUserId) async {
    final resp = await _client.dio.post(
      '/operator/peyks/$peykUserId/call/',
      data: {'consent_acknowledged': true},
    );
    return Map<String, dynamic>.from(resp.data as Map);
  }

  /// Operator → vendor call (ask about availability / readiness).
  /// Keys on the VendorProfile id.
  Future<Map<String, dynamic>> callVendor(String vendorId) async {
    final resp = await _client.dio.post(
      '/operator/vendors/$vendorId/call/',
      data: {'consent_acknowledged': true},
    );
    return Map<String, dynamic>.from(resp.data as Map);
  }

  // ── Assign a peyk to an order ──
  Future<void> assignPeyk(String orderId, String peykUserId) async {
    await _client.dio.post('/delivery/assignments/', data: {
      'order': orderId,
      'peyk': peykUserId,
    });
  }

  // ── Vendor checklist (operator: vendors + items in their city) ──
  Future<List<VendorChecklistModel>> getVendorChecklist() async {
    final resp = await _client.dio.get('/operator/vendors/checklist/');
    return parseList(resp.data, VendorChecklistModel.fromJson);
  }

  Future<void> setItemAvailability(String itemId, bool available) async {
    await _client.dio.patch(
      '/operator/items/$itemId/availability/',
      data: {'is_available': available},
    );
  }

  Future<void> setItemPrice(String itemId, int price) async {
    await _client.dio.patch('/operator/items/$itemId/price/', data: {'price': price});
  }

  // ── Vendor menu (the vendor manages their own catalog items) ──
  Future<List<CategoryModel>> getCategories() async {
    final resp = await _client.dio.get('/catalog/categories/');
    return parseList(resp.data, CategoryModel.fromJson);
  }

  /// The vendor's own items (filter by their VendorProfile id).
  Future<List<MenuItem>> getMyItems(String vendorId) async {
    final resp = await _client.dio.get(
      '/catalog/items/',
      queryParameters: {'vendor': vendorId},
    );
    return parseList(resp.data, MenuItem.fromJson);
  }

  /// Create a new meal/item. Vendor is bound server-side from the token.
  Future<MenuItem> createItem({
    required String name,
    required int price,
    required String categoryId,
    required String city,
    String description = '',
  }) async {
    final resp = await _client.dio.post('/catalog/items/', data: {
      'name': name,
      'price': price,
      'category': categoryId,
      'city': city,
      'description': description,
      'is_available': true,
    });
    return MenuItem.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Owner vendor updates their own item (availability and/or price).
  Future<void> updateItem(String itemId, {bool? isAvailable, int? price}) async {
    await _client.dio.patch('/catalog/items/$itemId/', data: {
      if (isAvailable != null) 'is_available': isAvailable,
      if (price != null) 'price': price,
    });
  }
}
