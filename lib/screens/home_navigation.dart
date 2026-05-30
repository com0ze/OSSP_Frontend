import 'package:flutter/material.dart';
import '/screens/chatting_list.dart';
import '/screens/rental_list_screen.dart';
import '/screens/rental_request_screen.dart';
import '/screens/user_profile_screen.dart';
import '/managers/location_manager.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    RentalRequestScreen(),
    RentalListScreen(),
    ChattingListScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // 로그인 후 메인 화면에 진입한 시점에 위치 추적을 시작한다.
    // (앱 시작 시점이 아니라 이 시점에 권한을 요청해야 사용자 맥락에 자연스럽다)
    LocationManager().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: '요청하기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: '대여 목록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
