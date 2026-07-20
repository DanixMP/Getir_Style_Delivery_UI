import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/address_model.dart';

/// Locally persisted address book + the currently selected delivery address.
/// (The backend has no address API yet; orders take a free-text address.)
class AddressProvider extends ChangeNotifier {
  AddressProvider(this._prefs) {
    _load();
  }

  static const _listKey = 'addresses';
  static const _selectedKey = 'selected_address_id';

  final SharedPreferences _prefs;
  List<AddressModel> _addresses = [];
  String? _selectedId;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);

  bool get hasAddresses => _addresses.isNotEmpty;

  AddressModel? get selected {
    if (_selectedId == null) return null;
    for (final a in _addresses) {
      if (a.id == _selectedId) return a;
    }
    return null;
  }

  void _load() {
    final raw = _prefs.getString(_listKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _addresses = list
            .whereType<Map<String, dynamic>>()
            .map(AddressModel.fromJson)
            .toList();
      } catch (_) {
        _addresses = [];
      }
    }
    _selectedId = _prefs.getString(_selectedKey);
    if (selected == null && _addresses.isNotEmpty) {
      _selectedId = _addresses.first.id;
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _listKey,
      jsonEncode(_addresses.map((a) => a.toJson()).toList()),
    );
    if (_selectedId != null) {
      await _prefs.setString(_selectedKey, _selectedId!);
    } else {
      await _prefs.remove(_selectedKey);
    }
  }

  Future<AddressModel> add({
    required String title,
    required String details,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    final address = AddressModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      details: details.trim(),
      city: city.trim(),
      latitude: latitude,
      longitude: longitude,
    );
    _addresses = [..._addresses, address];
    _selectedId = address.id; // newly added becomes the selected one
    await _persist();
    notifyListeners();
    return address;
  }

  Future<void> select(String id) async {
    if (_selectedId == id) return;
    _selectedId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> update(
    String id, {
    String? title,
    String? details,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index < 0) return;
    final old = _addresses[index];
    final next = AddressModel(
      id: old.id,
      title: title ?? old.title,
      details: details ?? old.details,
      city: city ?? old.city,
      latitude: latitude ?? old.latitude,
      longitude: longitude ?? old.longitude,
    );
    _addresses = [
      for (var i = 0; i < _addresses.length; i++)
        if (i == index) next else _addresses[i],
    ];
    await _persist();
    notifyListeners();
  }

  bool get hasMappedAddress {
    final current = selected;
    return current != null && current.hasCoordinates;
  }

  /// Saves map-picked location as the first address (or updates it) and selects it.
  Future<void> saveAsDefaultFromMap({
    required String details,
    required String city,
    required double latitude,
    required double longitude,
    String title = 'خانه',
  }) async {
    if (_addresses.isEmpty) {
      await add(
        title: title,
        details: details,
        city: city,
        latitude: latitude,
        longitude: longitude,
      );
      return;
    }
    final first = _addresses.first;
    await update(
      first.id,
      title: title,
      details: details,
      city: city,
      latitude: latitude,
      longitude: longitude,
    );
    _selectedId = first.id;
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _addresses = _addresses.where((a) => a.id != id).toList();
    if (_selectedId == id) {
      _selectedId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
    await _persist();
    notifyListeners();
  }
}
