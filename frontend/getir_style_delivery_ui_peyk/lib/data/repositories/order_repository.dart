import '../../core/network/api_client.dart';
import '../../core/network/api_parsing.dart';
import '../models/order_model.dart';

class OrderRepository {
  OrderRepository(this._client);

  final ApiClient _client;

  /// GET /orders/ — for a peyk this returns the orders assigned to them.
  Future<List<OrderModel>> getAssignedOrders() async {
    final resp = await _client.dio.get('/orders/');
    return parseList(resp.data, OrderModel.fromJson);
  }

  /// PATCH /orders/{id}/status/ — progress an assigned order.
  /// [deliveryCode] is the 6-digit handoff PIN required to complete delivery.
  Future<OrderModel> updateStatus(
    String id,
    String status, {
    String? deliveryCode,
  }) async {
    final resp = await _client.dio.patch(
      '/orders/$id/status/',
      data: {
        'status': status,
        if (deliveryCode != null) 'delivery_code': deliveryCode,
      },
    );
    return OrderModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
