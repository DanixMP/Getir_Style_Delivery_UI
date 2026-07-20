import '../../core/network/api_parsing.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });

  final String id;
  final String itemId;
  final String itemName;
  final int quantity;
  final int unitPrice;

  int get lineTotal => unitPrice * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as String,
        itemId: json['item'] as String,
        itemName: json['item_name'] as String? ?? '',
        quantity: parseInt(json['quantity']),
        unitPrice: parseInt(json['unit_price']),
      );
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.deliveryType,
    required this.paymentMethod,
    required this.totalAmount,
    this.isPaid = false,
    this.vendorId,
    this.vendorName = '',
    this.deliveryAddress = '',
    this.deliveryCity = '',
    this.customerNotes = '',
    this.items = const [],
    this.createdAt,
  });

  final String id;
  final String status;
  final String deliveryType;
  final String paymentMethod;
  final int totalAmount;
  final bool isPaid;
  final String? vendorId;
  final String vendorName;
  final String deliveryAddress;
  final String deliveryCity;
  final String customerNotes;
  final List<OrderItemModel> items;
  final DateTime? createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(OrderItemModel.fromJson)
            .toList()
        : <OrderItemModel>[];
    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending',
      deliveryType: json['delivery_type'] as String? ?? 'in_city',
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      totalAmount: parseInt(json['total_amount']),
      isPaid: json['is_paid'] as bool? ?? false,
      vendorId: json['vendor'] as String?,
      vendorName: json['vendor_name'] as String? ?? '',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryCity: json['delivery_city'] as String? ?? '',
      customerNotes: json['customer_notes'] as String? ?? '',
      items: items,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

/// A single line for creating an order: item id + quantity.
class OrderLineInput {
  const OrderLineInput({required this.itemId, required this.quantity});

  final String itemId;
  final int quantity;

  Map<String, dynamic> toJson() => {'item': itemId, 'quantity': quantity};
}
