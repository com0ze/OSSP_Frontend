import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'managers/theme_mode_manager.dart';
import 'package:open_source_software/managers/active_notification_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:open_source_software/app_keys.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/screens/home_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 💡 스마트폰(Android) 환경으로 타겟을 바꿨기 때문에,
  // 이제 아래 if문 안으로 들어가 파이어베이스 심장 충격기가 정상 기동됩니다!
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Firebase.initializeApp();
  }
  await activeNotificationManager.initialize();
  activeNotificationManager.updateDeviceTokenToServer();

  await LoginManager().initAutoLogin();

  LoginManager.setForceLogoutHandler((message) async {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
    await Future.delayed(const Duration(milliseconds: 300));
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModeManager = ThemeModeManager();
    return ListenableBuilder(
      listenable: themeModeManager,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '물건 대여',
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        themeMode: themeModeManager.mode == ThemeMode.dark
            ? ThemeMode.dark
            : themeModeManager.mode == ThemeMode.light
            ? ThemeMode.light
            : ThemeMode.system,

        // ThemeData는 MaterialApp의 테마 설정을 담당하는 클래스입니다. 라이트 모드와 다크 모드 각각에 대해 ThemeData를 설정할 수 있습니다.
        // 2. 라이트 모드일 때의 ThemeData
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: Colors.blue, // 메인 색상만 전달하면
                brightness: Brightness
                    .light, // 전체 팔레트(Primary, Surface, OnPrimary 등)를 자동으로 생성
              ).copyWith(
                onSurfaceVariant:
                    Colors.grey[700], // 라이트 모드에서 SurfaceVariant 색상
              ),
        ),

        // 3. 다크 모드일 때의 ThemeData
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: Colors.lightBlue, // 메인 색상만 전달하면
                brightness: Brightness
                    .dark, // 전체 팔레트(Primary, Surface, OnPrimary 등)를 자동으로 생성
              ).copyWith(
                onSurfaceVariant: Colors.grey[400], // 다크 모드에서 SurfaceVariant 색상
                surface: Colors.grey[900],
              ),
        ),

        // 자동 로그인 성공 시 바로 메인 화면 진입
        home: LoginManager().isLoggedIn
            ? const HomeNavigation()
            : const LoginScreen(),
      ),
    );
  }
}
