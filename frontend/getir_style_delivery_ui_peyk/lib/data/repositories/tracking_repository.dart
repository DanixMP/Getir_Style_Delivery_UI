import '../../core/network/api_client.dart';

class TrackingRepository {
  TrackingRepository(this._client);

  final ApiClient _client;

  /// POST /tracking/location/ — peyk posts a GPS update. When [orderId] is set,
  /// the backend broadcasts it to that order's live-tracking group.
  Future<void> postLocation({
    required double latitude,
    required double longitude,
    String? orderId,
  }) async {
    await _client.dio.post('/tracking/location/', data: {
      'latitude': latitude,
      'longitude': longitude,
      if (orderId != null) 'order_id': orderId,
    });
  }
}
