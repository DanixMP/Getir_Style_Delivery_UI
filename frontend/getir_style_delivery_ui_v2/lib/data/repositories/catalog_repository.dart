import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_parsing.dart';
import '../models/category_model.dart';
import '../models/home_promo_model.dart';
import '../models/item_model.dart';
import '../models/vendor_model.dart';

class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  Future<List<CategoryModel>> getCategories() async {
    final resp = await _client.dio.get('/catalog/categories/');
    return parseList(resp.data, CategoryModel.fromJson);
  }

  Future<List<VendorModel>> getVendors({
    String? city,
    String? categorySlug,
    bool? supportsDineIn,
  }) async {
    final resp = await _client.dio.get(
      '/catalog/vendors/',
      queryParameters: {
        if (city != null) 'city': city,
        if (categorySlug != null) 'category': categorySlug,
        if (supportsDineIn == true) 'supports_dine_in': true,
      },
    );
    return parseList(resp.data, VendorModel.fromJson);
  }

  Future<List<ItemModel>> getItems({
    String? city,
    String? categorySlug,
    String? vendorId,
    String? search,
    String? ordering,
  }) async {
    final resp = await _client.dio.get(
      '/catalog/items/',
      queryParameters: {
        if (city != null) 'city': city,
        if (categorySlug != null) 'category': categorySlug,
        if (vendorId != null) 'vendor': vendorId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (ordering != null) 'ordering': ordering,
      },
    );
    return parseList(resp.data, ItemModel.fromJson);
  }

  /// GET /catalog/home-promo/ — banners, discounts, today's specials.
  Future<HomePromoModel> getHomePromo({String? city}) async {
    try {
      final resp = await _client.dio.get(
        '/catalog/home-promo/',
        queryParameters: {if (city != null && city.isNotEmpty) 'city': city},
      );
      return HomePromoModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Missing or broken promo endpoint — keep home usable.
      final code = e.response?.statusCode;
      if (code == null || code == 404 || code >= 500) {
        return const HomePromoModel();
      }
      rethrow;
    }
  }
}
