import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/getir_style_delivery_ui_service.dart';

class ServiceProvider extends ChangeNotifier {
  ServiceProvider(this._prefs) {
    final stored = _prefs.getString(_storageKey);
    if (stored != null) {
      try {
        _selected = GetirStyleDeliveryUiServiceId.values.byName(stored);
      } catch (_) {
        _selected = null;
      }
    }
  }

  static const _storageKey = 'selected_getir_style_delivery_ui_service';

  final SharedPreferences _prefs;
  GetirStyleDeliveryUiServiceId? _selected;

  GetirStyleDeliveryUiService? get selected =>
      _selected == null ? null : getirStyleDeliveryUiServiceById(_selected!);

  bool get hasService => _selected != null;

  Future<void> select(GetirStyleDeliveryUiServiceId id) async {
    _selected = id;
    await _prefs.setString(_storageKey, id.name);
    notifyListeners();
  }

  Future<void> clear() async {
    _selected = null;
    await _prefs.remove(_storageKey);
    notifyListeners();
  }
}
