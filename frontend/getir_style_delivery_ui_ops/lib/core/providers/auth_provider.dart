import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/auth_repository.dart';

/// Roles allowed to use the ops/vendor console.
const _allowedRoles = {'operator', 'admin', 'developer', 'vendor'};

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._auth, this._account);

  final AuthRepository _auth;
  final AccountRepository _account;

  UserModel? user;
  bool isLoading = true;
  String? error;
  String? lastDebugOtp;

  bool get isAuthenticated => user != null;
  bool get isVendor => user?.role == 'vendor';

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
        user = _allowedRoles.contains(me.role) ? me : null;
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
    lastDebugOtp = null;
    notifyListeners();
    try {
      lastDebugOtp = await _auth.requestOtp(phone);
      notifyListeners();
      return lastDebugOtp;
    } catch (_) {
      error = 'ارسال کد ناموفق بود.';
      notifyListeners();
      return null;
    }
  }

  Future<bool> _finishLogin() async {
    final me = await _account.getMe();
    if (!_allowedRoles.contains(me.role)) {
      await _auth.logout();
      user = null;
      error = 'این حساب دسترسی اپراتور/فروشنده ندارد.';
      notifyListeners();
      return false;
    }
    user = me;
    notifyListeners();
    return true;
  }

  Future<bool> verifyOtp(String phone, String code) async {
    error = null;
    try {
      await _auth.verifyOtp(phone, code);
      return await _finishLogin();
    } catch (_) {
      error = 'کد نامعتبر یا منقضی شده است.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    error = null;
    try {
      await _auth.login(phone, password);
      return await _finishLogin();
    } catch (_) {
      error = 'ورود ناموفق. شماره یا رمز را بررسی کنید.';
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
