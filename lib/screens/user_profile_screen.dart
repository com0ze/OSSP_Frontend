import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/rental_item.dart';
import '../extensions/rental_status_extension.dart';
import 'chat_screen.dart';
import 'lender_profile_screen.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import '../screens/setting_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final User _currentUser = User(
    id: 'current',
    name: '홍길동',
    email: 'hong@example.com',
    score: 88,
    dealHistory: List.generate(15, (i) => 'deal$i'),
  );

  final List<RentalItem> _borrowedItems = [];
  final List<RentalItem> _lentItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateSampleData();
  }

  void _generateSampleData() {
    _borrowedItems.addAll([
      RentalItem(
        id: 'b1',
        title: '드릴 대여',
        itemName: '전동 드릴',
        location: '서울시 강남구',
        price: 10000,
        description: '가구 조립용',
        preferences: '',
        requester: _currentUser,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: RentalStatus.inProgress,
        lender: User(
          id: 'l1',
          name: '김대여',
          email: 'lender@example.com',
          score: 90,
        ),
      ),
      RentalItem(
        id: 'b2',
        title: '캠핑 텐트',
        itemName: '4인용 텐트',
        location: '서울시 마포구',
        price: 30000,
        description: '캠핑용',
        preferences: '',
        requester: _currentUser,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        status: RentalStatus.returned,
        lender: User(
          id: 'l2',
          name: '이빌려',
          email: 'lender2@example.com',
          score: 85,
        ),
      ),
    ]);

    _lentItems.addAll([
      RentalItem(
        id: 'l1',
        title: '카메라 대여',
        itemName: '미러리스 카메라',
        location: '서울시 송파구',
        price: 25000,
        description: '여행용',
        preferences: '',
        requester: User(
          id: 'r1',
          name: '박여행',
          email: 'renter@example.com',
          score: 82,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: RentalStatus.matchConfirmed,
        lender: _currentUser,
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.01; // 1% 여백

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: responsivePadding),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          UserInfoHeader(user: _currentUser, showEmail: true),
          const Divider(height: 1),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '빌린 물건'),
              Tab(text: '빌려준 물건'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItemList(_borrowedItems, isBorrowed: true),
                _buildItemList(_lentItems, isBorrowed: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(List<RentalItem> items, {required bool isBorrowed}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBorrowed ? Icons.inbox : Icons.folder_open,
              size: 64,
              color: context.onSurfaceVariantColor,
            ),
            const SizedBox(height: 16),
            Text(
              isBorrowed ? '빌린 물건이 없습니다' : '빌려준 물건이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: context.onSurfaceVariantColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final otherUser = isBorrowed ? item.lender! : item.requester;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(rentalItem: item, otherUser: otherUser),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.status.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: item.status.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(color: context.onSurfaceVariantColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        child: Text(
                          otherUser.name[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(otherUser.name),
                      const Spacer(),
                      Text(
                        '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
