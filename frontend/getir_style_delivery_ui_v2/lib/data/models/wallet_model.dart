import '../../core/network/api_parsing.dart';

class WalletModel {
  const WalletModel({
    required this.id,
    required this.balance,
    this.isActive = true,
  });

  final String id;
  final int balance; // Tomans
  final bool isActive;

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json['id'] as String,
        balance: parseInt(json['balance']),
        isActive: json['is_active'] as bool? ?? true,
      );
}

class WalletTransactionModel {
  const WalletTransactionModel({
    required this.id,
    required this.direction,
    required this.txnType,
    required this.amount,
    required this.balanceAfter,
    this.description = '',
    this.orderId,
    this.createdAt,
  });

  final String id;
  final String direction; // credit | debit
  final String txnType; // topup | order_payment | refund | adjustment
  final int amount;
  final int balanceAfter;
  final String description;
  final String? orderId;
  final DateTime? createdAt;

  bool get isCredit => direction == 'credit';

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        id: json['id'] as String,
        direction: json['direction'] as String? ?? 'credit',
        txnType: json['txn_type'] as String? ?? 'adjustment',
        amount: parseInt(json['amount']),
        balanceAfter: parseInt(json['balance_after']),
        description: json['description'] as String? ?? '',
        orderId: json['order'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      );
}
