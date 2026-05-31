import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageManager {
  static final TokenStorageManager _instance = TokenStorageManager._internal();
  factory TokenStorageManager() => _instance;
  TokenStorageManager._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessKey = 'ACCESS_TOKEN';
  static const String _refreshKey = 'REFRESH_TOKEN';

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> getAccessToken() async =>
      await _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() async =>
      await _storage.read(key: _refreshKey);

  Future<void> clearSessionTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<void> clearAll() async => await _storage.deleteAll();
}
