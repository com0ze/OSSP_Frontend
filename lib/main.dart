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
import '/models/rental_item.dart';
import '/screens/home_navigation.dart';
import '/screens/item_detail_screen.dart';

// 앱이 백그라운드/종료 상태일 때 FCM 메시지를 수신하는 top-level 핸들러.
// isolate가 분리되어 실행되므로 반드시 top-level 함수여야 하며,
// Firebase를 다시 초기화해야 합니다.
// 백그라운드/종료 상태에서 FCM 데이터 메시지를 수신하는 top-level 핸들러.
// notification 필드가 있는 메시지는 OS가 자동으로 알림을 표시한다.
// 이 핸들러는 별도 isolate에서 실행되므로 싱글톤/플랫폼 채널 사용 불가.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // notification이 항상 포함되므로 OS가 알림 표시를 담당한다.
  // 추후 뱃지 카운트 업데이트 등 순수 Dart 처리가 필요하면 여기에 추가한다.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 종료 상태에서 알림 탭으로 실행된 경우, runApp 전에 미리 확인한다.
  // runApp 후 비동기로 확인하면 HomeNavigation이 먼저 렌더링되어 화면 플래시가 발생한다.
  String? initialNotificationItemId;
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage?.data['type'] == 'RENTAL_REQUEST') {
      initialNotificationItemId = initialMessage?.data['requestId']?.toString();
    }
  }
  await activeNotificationManager.initialize();

  ApiClient();
  DataManager();

  // initAutoLogin() 전에 등록해야 자동 로그인 시에도 FCM 토큰이 서버에 등록된다.
  LoginManager.setLoginSuccessHandler(
    activeNotificationManager.updateDeviceTokenToServer,
  );

  await LoginManager().initAutoLogin();
  await ThemeModeManager().load();

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

  runApp(MyApp(initialNotificationItemId: initialNotificationItemId));
}

class MyApp extends StatefulWidget {
  final String? initialNotificationItemId;

  const MyApp({super.key, this.initialNotificationItemId});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 앱 종료 상태에서 알림으로 실행된 경우, 첫 프레임 직후 상세화면을 push한다.
    // API 호출 없이 placeholder만 사용하므로 딜레이가 없어 flash가 최소화된다.
    final id = widget.initialNotificationItemId;
    if (id != null && LoginManager().isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(item: RentalItem.placeholder(id)),
          ),
        );
      });
    }
  }

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

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ).copyWith(onSurfaceVariant: Colors.grey[700]),
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            brightness: Brightness.dark,
          ).copyWith(
            onSurfaceVariant: Colors.grey[400],
            surface: Colors.grey[900],
          ),
        ),

        home: LoginManager().isLoggedIn
            ? const HomeNavigation()
            : const LoginScreen(),
      ),
    );
  }
}
