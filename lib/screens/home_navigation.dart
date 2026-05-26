import 'package:flutter/material.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/managers/location_manager.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/screens/chatting_list.dart';
import 'package:open_source_software/screens/rental_list_screen.dart';
import 'package:open_source_software/screens/rental_request_screen.dart';
import 'package:open_source_software/screens/user_profile_screen.dart';

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

    DataManager().initCache();
    LocationManager().initialize();
    LocationManager().onBuildingChanged = (buildingName) {
      LoginManager().updateCurrentBuilding(buildingName);
    };
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
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}