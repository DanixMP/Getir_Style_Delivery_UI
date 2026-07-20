import '../../data/repositories/account_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/communications_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/tracking_repository.dart';
import '../network/api_client.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  late final ApiClient apiClient;
  late final AuthRepository auth;
  late final AccountRepository account;
  late final CommunicationsRepository communications;
  late final OrderRepository orders;
  late final TrackingRepository tracking;

  void init() {
    apiClient = ApiClient();
    auth = AuthRepository(apiClient);
    account = AccountRepository(apiClient);
    communications = CommunicationsRepository(apiClient);
    orders = OrderRepository(apiClient);
    tracking = TrackingRepository(apiClient);
  }
}
