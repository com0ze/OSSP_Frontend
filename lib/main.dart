import 'package:flutter/material.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/managers/theme_mode_manager.dart';
import 'package:open_source_software/screens/home_navigation.dart';
import 'package:open_source_software/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 자동 로그인 구현
  await LoginManager().initAutoLogin();
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
