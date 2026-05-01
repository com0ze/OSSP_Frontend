import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import '../managers/theme_mode_manager.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.brightness_6, color: context.primaryColor),
            title: const Text('테마 설정'),
            subtitle: const Text('테마 모드를 설정합니다. '),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ThemeModeManager().changeThemeMode(ThemeMode.light);
                  },
                  child: Icon(Icons.light_mode),
                ),
                ElevatedButton(
                  onPressed: () {
                    ThemeModeManager().changeThemeMode(ThemeMode.dark);
                  },
                  child: Icon(Icons.dark_mode),
                ),
                ElevatedButton(
                  onPressed: () {
                    ThemeModeManager().changeThemeMode(ThemeMode.system);
                  },
                  child: Icon(Icons.brightness_auto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
