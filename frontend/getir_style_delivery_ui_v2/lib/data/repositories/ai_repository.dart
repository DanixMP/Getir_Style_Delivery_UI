import '../../core/network/api_client.dart';
import '../models/discount_model.dart';
import '../models/item_model.dart';

class AiRepository {
  AiRepository(this._client);

  final ApiClient _client;

  Future<List<ItemModel>> getRecommendations({
    String? city,
    int limit = 10,
  }) async {
    final resp = await _client.dio.get(
      '/ai/recommendations/',
      queryParameters: {
        if (city != null) 'city': city,
        'limit': limit,
      },
    );
    final list = resp.data is List ? resp.data as List<dynamic> : <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ItemModel.fromJson)
        .toList();
  }

  Future<List<DiscountModel>> getDiscounts() async {
    final resp = await _client.dio.get('/ai/discounts/');
    final list = resp.data is List ? resp.data as List<dynamic> : <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(DiscountModel.fromJson)
        .toList();
  }
}
