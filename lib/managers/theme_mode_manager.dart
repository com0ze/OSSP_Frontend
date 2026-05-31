import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeModeManager extends ChangeNotifier {
  static final ThemeModeManager _instance = ThemeModeManager._internal();

  factory ThemeModeManager() {
    return _instance;
  }

  ThemeModeManager._internal();

  static const _storage = FlutterSecureStorage();
  static const _key = 'THEME_MODE';

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final saved = await _storage.read(key: _key);
    if (saved != null) {
      _mode = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  void changeThemeMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _storage.write(key: _key, value: mode.name);
  }
}
