import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';

/// Debug tools are only available in debug builds for developer-role users.
bool showDevTools(UserModel? user) {
  if (!kDebugMode || user == null) return false;
  return user.role == 'developer';
}
