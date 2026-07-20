import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._prefs) {
    final code = _prefs.getString(_key) ?? 'fa';
    _locale = Locale(code);
  }

  static const _key = 'getir_style_delivery_ui_locale';

  final SharedPreferences _prefs;
  late Locale _locale;

  Locale get locale => _locale;

  bool get isRtl =>
      _locale.languageCode == 'fa' || _locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  static const supportedLocales = [
    Locale('fa'),
    Locale('en'),
    Locale('ar'),
    Locale('tr'),
  ];

  String languageLabel(String code) => switch (code) {
        'fa' => 'Persian',
        'en' => 'English',
        'ar' => 'Arabic',
        'tr' => 'Turkish',
        _ => code,
      };

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }
}
