import '../../core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// Returns [debug_code] when the server runs with DEBUG=True (dev only).
  Future<String?> requestOtp(String phone) async {
    final resp = await _client.dio.post('/auth/otp/request/', data: {'phone': phone});
    return resp.data['debug_code'] as String?;
  }

  Future<void> verifyOtp(String phone, String code) async {
    final resp = await _client.dio.post(
      '/auth/otp/verify/',
      data: {'phone': phone, 'code': code},
    );
    await _client.saveTokens(
      resp.data['access'] as String,
      resp.data['refresh'] as String,
    );
  }

  /// Password login (operators/vendors created via admin have a password).
  Future<void> login(String phone, String password) async {
    final resp = await _client.dio.post(
      '/auth/login/',
      data: {'phone': phone, 'password': password},
    );
    await _client.saveTokens(
      resp.data['access'] as String,
      resp.data['refresh'] as String,
    );
  }

  Future<void> logout() async {
    final refresh = await _client.refreshToken;
    try {
      if (refresh != null) {
        await _client.dio.post('/auth/logout/', data: {'refresh': refresh});
      }
    } catch (_) {}
    await _client.clearTokens();
  }

  Future<bool> isLoggedIn() => _client.hasToken();
}
