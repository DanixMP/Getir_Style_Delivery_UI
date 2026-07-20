import '../../core/network/api_client.dart';

class PaymentRepository {
  PaymentRepository(this._client);

  final ApiClient _client;

  /// POST /payments/initiate/ — Zarinpal online payment for an order.
  /// Returns the gateway payment URL.
  Future<String> initiate(String orderId) async {
    final resp = await _client.dio.post(
      '/payments/initiate/',
      data: {'order_id': orderId},
    );
    return resp.data['payment_url'] as String;
  }

  /// GET /payments/{order_id}/status/ — { status, ref_id }.
  Future<Map<String, dynamic>> status(String orderId) async {
    final resp = await _client.dio.get('/payments/$orderId/status/');
    return Map<String, dynamic>.from(resp.data as Map);
  }
}
