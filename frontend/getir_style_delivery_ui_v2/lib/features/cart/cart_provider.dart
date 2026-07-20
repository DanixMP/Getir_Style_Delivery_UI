import 'package:flutter/foundation.dart';

import '../../data/models/item_model.dart';
import '../../data/models/order_model.dart';

class CartLine {
  CartLine({required this.item, this.quantity = 1});

  final ItemModel item;
  int quantity;

  int get lineTotal => item.price * quantity;
}

enum AddToCartResult { added, increased, vendorMismatch }

enum CartFulfillmentType { delivery, dineIn }

/// In-memory shopping cart. Enforces a single vendor per cart because the
/// backend creates one order per vendor (all items must share `vendor`).
class CartProvider extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  CartFulfillmentType _fulfillmentType = CartFulfillmentType.delivery;
  String? _tableId;
  String? _tableLabel;

  List<CartLine> get lines => _lines.values.toList(growable: false);

  bool get isEmpty => _lines.isEmpty;

  CartFulfillmentType get fulfillmentType => _fulfillmentType;
  String? get tableId => _tableId;
  String? get tableLabel => _tableLabel;
  bool get isDineIn => _fulfillmentType == CartFulfillmentType.dineIn;

  int get itemCount =>
      _lines.values.fold(0, (sum, line) => sum + line.quantity);

  int get subtotal =>
      _lines.values.fold(0, (sum, line) => sum + line.lineTotal);

  String? get vendorId =>
      _lines.isEmpty ? null : _lines.values.first.item.vendorId;

  String get vendorName =>
      _lines.isEmpty ? '' : _lines.values.first.item.vendorName;

  /// Adds an item (optionally several). Rejects items from a different vendor
  /// than the current cart.
  AddToCartResult add(ItemModel item, {int quantity = 1}) {
    final qty = quantity < 1 ? 1 : quantity;
    if (_lines.isNotEmpty && vendorId != null && item.vendorId != vendorId) {
      return AddToCartResult.vendorMismatch;
    }
    final existing = _lines[item.id];
    if (existing != null) {
      existing.quantity += qty;
      notifyListeners();
      return AddToCartResult.increased;
    }
    _lines[item.id] = CartLine(item: item, quantity: qty);
    notifyListeners();
    return AddToCartResult.added;
  }

  void increment(String itemId) {
    final line = _lines[itemId];
    if (line == null) return;
    line.quantity += 1;
    notifyListeners();
  }

  void decrement(String itemId) {
    final line = _lines[itemId];
    if (line == null) return;
    line.quantity -= 1;
    if (line.quantity <= 0) {
      _lines.remove(itemId);
    }
    notifyListeners();
  }

  void remove(String itemId) {
    _lines.remove(itemId);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _fulfillmentType = CartFulfillmentType.delivery;
    _tableId = null;
    _tableLabel = null;
    notifyListeners();
  }

  void setDineInContext({
    required String tableId,
    required String tableLabel,
  }) {
    _fulfillmentType = CartFulfillmentType.dineIn;
    _tableId = tableId;
    _tableLabel = tableLabel;
    notifyListeners();
  }

  void clearDineInContext() {
    _fulfillmentType = CartFulfillmentType.delivery;
    _tableId = null;
    _tableLabel = null;
    notifyListeners();
  }

  /// Replace the whole cart with a single item (used after a vendor switch).
  void replaceWith(ItemModel item, {int quantity = 1}) {
    _lines
      ..clear()
      ..[item.id] = CartLine(item: item, quantity: quantity < 1 ? 1 : quantity);
    notifyListeners();
  }

  /// Order lines for the create-order API payload.
  List<OrderLineInput> toOrderLines() => _lines.values
      .map((l) => OrderLineInput(itemId: l.item.id, quantity: l.quantity))
      .toList();
}
