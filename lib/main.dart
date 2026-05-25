import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/api/api_client.dart';
import '/screens/login_screen.dart';
import '/managers/active_notification_manager.dart';
import '/managers/data_manager.dart';
import '/managers/theme_mode_manager.dart';
import '/app_keys.dart';
import '/managers/login_manager.dart';
import '/screens/home_navigation.dart';

// 앱이 백그라운드/종료 상태일 때 FCM 메시지를 수신하는 top-level 핸들러.
// isolate가 분리되어 실행되므로 반드시 top-level 함수여야 하며,
// Firebase를 다시 초기화해야 합니다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // 데이터 전용 메시지는 여기서 처리합니다.
  // notification 필드가 있는 메시지는 OS가 자동으로 알림 표시를 처리합니다.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  await activeNotificationManager.initialize();
  activeNotificationManager.updateDeviceTokenToServer();

  ApiClient();
  DataManager();

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
