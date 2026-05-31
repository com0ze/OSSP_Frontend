import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/login_manager.dart';
import '/managers/theme_mode_manager.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _chatNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: context.primaryColor,
        foregroundColor: context.onPrimaryColor,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            subtitle: const Text('계정에서 로그아웃합니다.'),
            onTap: () => LoginManager().forceLogout('로그아웃되었습니다.'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.brightness_6, color: context.primaryColor),
            title: const Text('테마 설정'),
            subtitle: const Text('테마 모드를 설정합니다. '),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeButton(context, ThemeMode.light, Icons.light_mode),
                _buildThemeButton(context, ThemeMode.dark, Icons.dark_mode),
                _buildThemeButton(
                  context,
                  ThemeMode.system,
                  Icons.brightness_auto,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.notifications_outlined,
              color: context.primaryColor,
            ),
            title: const Text('채팅 알림 설정'),
            subtitle: const Text('채팅 알림을 켜거나 끕니다.'),
            trailing: Switch(
              value: _chatNotificationsEnabled,
              onChanged: (value) =>
                  setState(() => _chatNotificationsEnabled = value),
            ),
          ),
        ],
      ),
    );
  }

  ListenableBuilder _buildThemeButton(
    BuildContext context,
    ThemeMode mode,
    IconData icon,
  ) {
    return ListenableBuilder(
      listenable: ThemeModeManager(),
      builder: (context, child) {
        final isSelected = ThemeModeManager().mode == mode;
        final double screenWidth = MediaQuery.of(context).size.width;
        return ElevatedButton(
          onPressed: () {
            ThemeModeManager().changeThemeMode(mode);
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(5.0),
            minimumSize: Size.zero,

            // 터치 영역(물결 효과 등)을 버튼의 실제 크기만큼만 딱 맞게 줄입니다.
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,

            backgroundColor: isSelected
                ? context.primaryColor
                : context.secondaryColor.withValues(alpha: 0.3),
          ),
          child: Icon(
            icon,
            color: context.onPrimaryColor,
            size: (screenWidth * 0.075).clamp(0.0, 28.0),
          ),
        );
      },
    );
  }
}
