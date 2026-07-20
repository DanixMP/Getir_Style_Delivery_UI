import '../../data/repositories/account_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/ops_repository.dart';
import '../network/api_client.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  late final ApiClient apiClient;
  late final AuthRepository auth;
  late final AccountRepository account;
  late final OpsRepository ops;

  void init() {
    apiClient = ApiClient();
    auth = AuthRepository(apiClient);
    account = AccountRepository(apiClient);
    ops = OpsRepository(apiClient);
  }
}
