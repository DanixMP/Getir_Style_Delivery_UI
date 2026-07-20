import 'package:flutter/foundation.dart';

import '../../data/models/dining_table_model.dart';

/// Holds the active dine-in flow: venue, panorama, and selected table.
class DineInSessionProvider extends ChangeNotifier {
  String? _vendorId;
  String? _vendorName;
  DiningTableModel? _selectedTable;
  String? _panoramaUrl;

  String? get vendorId => _vendorId;
  String? get vendorName => _vendorName;
  DiningTableModel? get selectedTable => _selectedTable;
  String? get panoramaUrl => _panoramaUrl;

  bool get hasTable => _selectedTable != null;
  bool get hasSession => _vendorId != null;

  void startVenue({
    required String vendorId,
    required String vendorName,
    String? panoramaUrl,
  }) {
    _vendorId = vendorId;
    _vendorName = vendorName;
    _panoramaUrl = panoramaUrl;
    _selectedTable = null;
    notifyListeners();
  }

  void selectTable(DiningTableModel table) {
    _selectedTable = table;
    notifyListeners();
  }

  void clear() {
    _vendorId = null;
    _vendorName = null;
    _selectedTable = null;
    _panoramaUrl = null;
    notifyListeners();
  }
}
