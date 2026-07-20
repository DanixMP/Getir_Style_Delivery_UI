import '../../data/repositories/account_repository.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/communications_repository.dart';
import '../../data/repositories/dine_in_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/tracking_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import '../network/api_client.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  late final ApiClient apiClient;
  late final AuthRepository auth;
  late final AccountRepository account;
  late final CatalogRepository catalog;
  late final DineInRepository dineIn;
  late final CommunicationsRepository communications;
  late final AiRepository ai;
  late final OrderRepository orders;
  late final WalletRepository wallet;
  late final PaymentRepository payments;
  late final TrackingRepository tracking;

  void init() {
    apiClient = ApiClient();
    auth = AuthRepository(apiClient);
    account = AccountRepository(apiClient);
    catalog = CatalogRepository(apiClient);
    dineIn = DineInRepository(apiClient);
    communications = CommunicationsRepository(apiClient);
    ai = AiRepository(apiClient);
    orders = OrderRepository(apiClient);
    wallet = WalletRepository(apiClient);
    payments = PaymentRepository(apiClient);
    tracking = TrackingRepository(apiClient);
  }
}
