import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _readAccess();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer ${await _readAccess()}';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final FlutterSecureStorage _storage;

  // In-memory token cache: avoids a secure-storage (keystore) read on every
  // request. `_loaded` tracks whether we've hydrated from storage yet.
  String? _accessCache;
  String? _refreshCache;
  bool _loaded = false;

  Dio get dio => _dio;

  /// Reads the access token, hydrating the in-memory cache from storage once.
  Future<String?> _readAccess() async {
    if (!_loaded) {
      _accessCache = await _storage.read(key: 'access_token');
      _refreshCache = await _storage.read(key: 'refresh_token');
      _loaded = true;
    }
    return _accessCache;
  }

  Future<String?> _readRefresh() async {
    if (!_loaded) await _readAccess();
    return _refreshCache;
  }

  Future<void> saveTokens(String access, String refresh) async {
    _accessCache = access;
    _refreshCache = refresh;
    _loaded = true;
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    _accessCache = null;
    _refreshCache = null;
    _loaded = true;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> get refreshToken => _readRefresh();

  Future<String?> get accessToken => _readAccess();

  Future<bool> hasToken() async {
    final token = await _readAccess();
    return token != null && token.isNotEmpty;
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _readRefresh();
    if (refresh == null) return false;
    try {
      final resp = await Dio().post(
        '${AppConfig.apiBaseUrl}/auth/token/refresh/',
        data: {'refresh': refresh},
      );
      final access = resp.data['access'] as String;
      _accessCache = access;
      await _storage.write(key: 'access_token', value: access);
      if (resp.data['refresh'] != null) {
        _refreshCache = resp.data['refresh'] as String;
        await _storage.write(key: 'refresh_token', value: _refreshCache);
      }
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }
}
