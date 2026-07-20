import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._auth, this._account);

  final AuthRepository _auth;
  final AccountRepository _account;

  UserModel? user;
  bool isLoading = true;
  String? error;
  String? lastDebugOtp;

  bool get isAuthenticated => user != null;

  Future<void> bootstrap() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (await _auth.isLoggedIn()) {
        user = await _account
            .getMe()
            .timeout(const Duration(seconds: 12), onTimeout: () {
          throw StateError('Profile request timed out');
        });
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
    } catch (e) {
      error = _requestOtpError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    error = null;
    notifyListeners();
    try {
      await _auth.verifyOtp(phone, code);
      user = await _account.getMe();
      notifyListeners();
      return true;
    } catch (e) {
      error = _verifyOtpError(e);
      user = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    error = null;
    notifyListeners();
    try {
      await _auth.login(phone, password);
      user = await _account.getMe();
      notifyListeners();
      return true;
    } catch (_) {
      error = 'ورود ناموفق. شماره یا رمز عبور را بررسی کنید.';
      user = null;
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

  String _requestOtpError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'اتصال به سرور برقرار نشد.\n${AppConfig.apiBaseUrl}';
      }
      final detail = e.response?.data;
      if (detail is Map && detail['detail'] != null) {
        return detail['detail'].toString();
      }
    }
    return 'ارسال کد ناموفق بود. سرور را بررسی کنید.';
  }

  String _verifyOtpError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'اتصال به سرور برقرار نشد.\n${AppConfig.apiBaseUrl}';
      }
      final detail = e.response?.data;
      if (detail is Map && detail['detail'] != null) {
        return detail['detail'].toString();
      }
    }
    return 'کد نامعتبر یا منقضی شده است.';
  }
}
