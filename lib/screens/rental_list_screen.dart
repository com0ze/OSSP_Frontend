import 'package:flutter/material.dart';
import '../models/rental_item.dart';
import '../models/user.dart';
import 'item_detail_screen.dart';
import 'package:open_source_software/extensions/theme_extension.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  final List<RentalItem> _rentalItems = _generateSampleData();

  static List<RentalItem> _generateSampleData() {
    final sampleUser = User(
      id: '1',
      name: '김철수',
      email: 'kim@example.com',
      score: 85,
      dealHistory: ['deal1', 'deal2', 'deal3'],
    );

    return [
      RentalItem(
        id: '1',
        title: '급하게 드릴 필요해요',
        itemName: '전동 드릴',
        location: '서울시 강남구',
        price: 10000,
        description: '가구 조립용으로 오늘 저녁까지 필요합니다',
        preferences: '오늘 저녁까지 필요합니다',
        requester: sampleUser,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      RentalItem(
        id: '2',
        title: '캠핑용 텐트 빌려주실 분',
        itemName: '4인용 텐트',
        location: '서울시 마포구',
        price: 30000,
        description: '이번 주말 캠핑 가는데 텐트가 필요합니다',
        preferences: '금요일 오후에 수령 가능합니다',
        requester: User(
          id: '2',
          name: '이영희',
          email: 'lee@example.com',
          score: 92,
          dealHistory: ['deal4', 'deal5'],
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      RentalItem(
        id: '3',
        title: '빔프로젝터 급구',
        itemName: '빔프로젝터',
        location: '서울시 송파구',
        price: 20000,
        description: '회사 프레젠테이션용으로 필요합니다',
        preferences: '내일 오전까지 필요',
        requester: User(
          id: '3',
          name: '박민수',
          email: 'park@example.com',
          score: 78,
          dealHistory: ['deal6'],
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('대여 가능한 물건'), centerTitle: true),
      body: _rentalItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '현재 대여 요청이 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rentalItems.length,
              itemBuilder: (context, index) {
                final item = _rentalItems[index];
                return _RentalItemCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(item: item),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _RentalItemCard extends StatelessWidget {
  final RentalItem item;
  final VoidCallback onTap;

  const _RentalItemCard({required this.item, required this.onTap});

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _getTimeAgo(item.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.shopping_basket,
                    size: 16,
                    color: context.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: context.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(item.location),
                  const Spacer(),
                  Text(
                    '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.onSurfaceVariantColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    child: Text(
                      item.requester.name[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.requester.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.star, size: 14, color: context.starColor),
                  const SizedBox(width: 2),
                  Text(
                    '${item.requester.score}점',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
