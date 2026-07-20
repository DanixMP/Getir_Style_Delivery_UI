import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/auth_repository.dart';

/// Auth state for the Peyk app. Only `role == 'peyk'` accounts are allowed in;
/// the shared OTP endpoint returns whatever role the phone is registered as.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._auth, this._account);

  final AuthRepository _auth;
  final AccountRepository _account;

  UserModel? user;
  bool isLoading = true;
  String? error;

  bool get isAuthenticated => user != null;

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    try {
      if (await _auth.isLoggedIn()) {
        final me = await _account
            .getMe()
            .timeout(const Duration(seconds: 12), onTimeout: () {
          throw StateError('Profile request timed out');
        });
        user = me.role == 'peyk' ? me : null;
        if (user == null) await _auth.logout();
      }
    } catch (_) {
      await _auth.logout();
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> requestOtp(String phone) async {
    error = null;
    notifyListeners();
    try {
      return await _auth.requestOtp(phone);
    } catch (_) {
      error = 'ارسال کد ناموفق بود. سرور را بررسی کنید.';
      notifyListeners();
      return null;
    }
  }

  /// Verifies OTP and enforces the peyk role. Returns false (and signs out)
  /// when the phone belongs to a non-courier account.
  Future<bool> verifyOtp(String phone, String code) async {
    error = null;
    notifyListeners();
    try {
      await _auth.verifyOtp(phone, code);
      final me = await _account.getMe();
      if (me.role != 'peyk') {
        await _auth.logout();
        user = null;
        error = 'این شماره به عنوان پیک ثبت نشده است.';
        notifyListeners();
        return false;
      }
      user = me;
      notifyListeners();
      return true;
    } catch (_) {
      error = 'کد نامعتبر یا منقضی شده است.';
      user = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerPeyk({
    required String phone,
    required String password,
    required String fullName,
    required String vehicleType,
  }) async {
    error = null;
    notifyListeners();
    try {
      await _auth.registerPeyk(
        phone: phone,
        password: password,
        fullName: fullName,
        vehicleType: vehicleType,
      );
      return true;
    } catch (_) {
      error = 'ثبت‌نام ناموفق بود. ممکن است این شماره قبلاً ثبت شده باشد.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? city,
  }) async {
    try {
      user = await _account.updateMe(
        fullName: fullName,
        email: email,
        city: city,
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    user = null;
    notifyListeners();
  }
}
