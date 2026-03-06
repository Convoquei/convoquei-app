import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');

  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<void> debugPrintTokens() async {
    assert(() {
      getAccessToken().then((t) => debugPrint('access_token: $t'));
      getRefreshToken().then((t) => debugPrint('refresh_token: $t'));
      return true;
    }());
  }
}
