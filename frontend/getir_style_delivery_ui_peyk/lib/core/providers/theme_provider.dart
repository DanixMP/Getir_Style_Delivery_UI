import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._prefs) {
    _isDark = _prefs.getBool(_key) ?? false;
  }

  static const _key = 'getir_style_delivery_ui_peyk_dark_theme';

  final SharedPreferences _prefs;
  late bool _isDark;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    await _prefs.setBool(_key, value);
    notifyListeners();
  }

  Future<void> toggle() => setDark(!_isDark);
}
