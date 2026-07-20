import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AccountRepository {
  AccountRepository(this._client);

  final ApiClient _client;

  Future<UserModel> getMe() async {
    final resp = await _client.dio.get('/accounts/me/');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// PATCH /accounts/me/ — update own editable fields (full_name, email, city).
  Future<UserModel> updateMe({
    String? fullName,
    String? email,
    String? city,
  }) async {
    final resp = await _client.dio.patch('/accounts/me/', data: {
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (city != null) 'city': city,
    });
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
