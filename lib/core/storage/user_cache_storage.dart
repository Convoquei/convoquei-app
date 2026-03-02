import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/models/user_model.dart';

/// Persists [UserModel] across app sessions using [SharedPreferences].
class UserCacheStorage {
  static const _key = 'cached_user_profile';

  Future<void> save(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
  }

  Future<UserModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

