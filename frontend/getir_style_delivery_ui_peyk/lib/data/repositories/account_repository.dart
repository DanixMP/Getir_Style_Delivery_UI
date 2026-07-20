import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AccountRepository {
  AccountRepository(this._client);

  final ApiClient _client;

  Future<UserModel> getMe() async {
    final resp = await _client.dio.get('/accounts/me/');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<UserModel> updateMe({
    String? fullName,
    String? email,
    String? city,
  }) async {
    final resp = await _client.dio.patch('/accounts/me/', data: {
      'full_name': ?fullName,
      'email': ?email,
      'city': ?city,
    });
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// PATCH /accounts/peyk/availability/ — peyk goes online/offline.
  Future<void> setAvailability(bool available) async {
    await _client.dio.patch(
      '/accounts/peyk/availability/',
      data: {'is_available': available},
    );
  }
}
