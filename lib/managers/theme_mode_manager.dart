import 'package:flutter/material.dart';

class ThemeModeManager extends ChangeNotifier {
  static final ThemeModeManager _instance = ThemeModeManager._internal();

  factory ThemeModeManager() {
    return _instance;
  }

  ThemeModeManager._internal();

  ThemeMode _mode = ThemeMode.system; // 시스템, 라이트, 다크

  ThemeMode get mode => _mode;

  void changeThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners(); // <--- 이 부분이 핵심! UI에게 변경을 알립니다.
  }
}
