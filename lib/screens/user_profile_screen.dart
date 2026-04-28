import 'package:flutter/material.dart';
import '../models/rental_item.dart';
import '../models/user.dart';
import 'chat_screen.dart';

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
    rating: 4.6,
    totalRentals: 15,
    totalLends: 8,
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
          rating: 4.8,
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
          rating: 4.5,
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
          rating: 4.3,
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

  String _getStatusText(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return '대기 중';
      case RentalStatus.matchConfirmed:
        return '매칭 확정';
      case RentalStatus.inProgress:
        return '대여 중';
      case RentalStatus.returned:
        return '반납 완료';
      case RentalStatus.reviewed:
        return '리뷰 완료';
    }
  }

  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return Colors.grey;
      case RentalStatus.matchConfirmed:
        return Colors.blue;
      case RentalStatus.inProgress:
        return Colors.orange;
      case RentalStatus.returned:
        return Colors.green;
      case RentalStatus.reviewed:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    _currentUser.name[0],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentUser.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      _currentUser.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      label: '대여한 물건',
                      value: _currentUser.totalRentals.toString(),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    _StatItem(
                      label: '빌려준 물건',
                      value: _currentUser.totalLends.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isBorrowed ? '빌린 물건이 없습니다' : '빌려준 물건이 없습니다',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                  builder: (context) => ChatScreen(
                    rentalItem: item,
                    otherUser: otherUser,
                  ),
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
                          color: _getStatusColor(item.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(item.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(item.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(color: Colors.grey),
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
                        '${item.price.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )}원',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
