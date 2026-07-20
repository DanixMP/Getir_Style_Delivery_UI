import '../../core/network/api_client.dart';
import '../../core/network/api_parsing.dart';
import '../models/order_model.dart';

class OrderRepository {
  OrderRepository(this._client);

  final ApiClient _client;

  /// POST /orders/ — create an order (customer).
  Future<OrderModel> createOrder({
    required String vendorId,
    required List<OrderLineInput> items,
    required String deliveryType, // in_city | inter_city
    required String paymentMethod, // online | cash | card_in_person | wallet
    required String deliveryAddress,
    required String deliveryCity,
    String customerNotes = '',
    String? fulfillmentType,
    String? diningTableId,
  }) async {
    final resp = await _client.dio.post('/orders/', data: {
      'vendor': vendorId,
      'delivery_type': deliveryType,
      'payment_method': paymentMethod,
      'delivery_address': deliveryAddress,
      'delivery_city': deliveryCity,
      'customer_notes': customerNotes,
      'items': items.map((e) => e.toJson()).toList(),
      if (fulfillmentType != null) 'fulfillment_type': fulfillmentType,
      if (diningTableId != null) 'dining_table': diningTableId,
    });
    return OrderModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// GET /orders/ — scoped to the caller's role.
  Future<List<OrderModel>> getOrders() async {
    final resp = await _client.dio.get('/orders/');
    return parseList(resp.data, OrderModel.fromJson);
  }

  /// GET /orders/{id}/
  Future<OrderModel> getOrder(String id) async {
    final resp = await _client.dio.get('/orders/$id/');
    return OrderModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// PATCH /orders/{id}/status/ — role-validated state transition.
  Future<OrderModel> updateStatus(String id, String status) async {
    final resp = await _client.dio.patch(
      '/orders/$id/status/',
      data: {'status': status},
    );
    return OrderModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
