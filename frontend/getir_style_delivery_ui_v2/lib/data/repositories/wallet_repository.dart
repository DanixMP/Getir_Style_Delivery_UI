import '../../core/network/api_client.dart';
import '../../core/network/api_parsing.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  WalletRepository(this._client);

  final ApiClient _client;

  /// GET /wallet/ — current user's wallet (created on first access).
  Future<WalletModel> getWallet() async {
    final resp = await _client.dio.get('/wallet/');
    return WalletModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// GET /wallet/transactions/ — paginated ledger.
  Future<List<WalletTransactionModel>> getTransactions() async {
    final resp = await _client.dio.get('/wallet/transactions/');
    return parseList(resp.data, WalletTransactionModel.fromJson);
  }

  /// POST /wallet/topup/initiate/ — returns the Zarinpal payment URL.
  Future<String> initiateTopUp(int amountToman) async {
    final resp = await _client.dio.post(
      '/wallet/topup/initiate/',
      data: {'amount': amountToman},
    );
    return resp.data['payment_url'] as String;
  }

  /// POST /wallet/pay-order/ — pay a wallet-method order from balance.
  /// Returns the wallet balance after the debit.
  Future<int> payOrder(String orderId) async {
    final resp = await _client.dio.post(
      '/wallet/pay-order/',
      data: {'order_id': orderId},
    );
    return parseInt(resp.data['balance_after']);
  }
}
