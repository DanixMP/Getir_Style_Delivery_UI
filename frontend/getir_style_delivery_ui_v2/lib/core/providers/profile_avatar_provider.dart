import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/preset_avatar.dart';

/// Persists the selected preset avatar per user (local until backend supports it).
class ProfileAvatarProvider extends ChangeNotifier {
  ProfileAvatarProvider(this._prefs);

  static String _key(String userId) => 'profile_avatar_$userId';

  final SharedPreferences _prefs;
  final Map<String, String> _cache = {};

  String avatarIdFor(String? userId) {
    if (userId == null || userId.isEmpty) return PresetAvatar.defaultId;
    return _cache[userId] ??
        _prefs.getString(_key(userId)) ??
        PresetAvatar.defaultId;
  }

  PresetAvatar avatarFor(String? userId) =>
      PresetAvatar.byId(avatarIdFor(userId));

  Future<void> setAvatar(String userId, String avatarId) async {
    _cache[userId] = avatarId;
    await _prefs.setString(_key(userId), avatarId);
    notifyListeners();
  }

  void warmCache(String? userId) {
    if (userId == null || userId.isEmpty) return;
    _cache[userId] = avatarIdFor(userId);
  }
}
