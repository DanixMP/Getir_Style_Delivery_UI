import '../../core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// Returns the dev `debug_code` when the server is in DEBUG mode.
  Future<String?> requestOtp(String phone) async {
    final resp = await _client.dio.post('/auth/otp/request/', data: {'phone': phone});
    return resp.data['debug_code'] as String?;
  }

  /// Verifies the OTP and stores the JWT tokens.
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

  /// Registers a new peyk (courier) account via the shared register endpoint.
  Future<void> registerPeyk({
    required String phone,
    required String password,
    required String fullName,
    required String vehicleType, // 'car' | 'motor'
    String city = 'Tehran',
  }) async {
    await _client.dio.post('/auth/register/', data: {
      'phone': phone,
      'password': password,
      'full_name': fullName,
      'role': 'peyk',
      'vehicle_type': vehicleType,
      'city': city,
    });
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
