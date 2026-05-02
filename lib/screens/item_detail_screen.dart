import 'package:flutter/material.dart';
import '../models/rental_item.dart';
import 'other_user_profile_screen.dart';
import 'chat_screen.dart';
import 'package:open_source_software/extensions/theme_extension.dart';

class ItemDetailScreen extends StatelessWidget {
  final RentalItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('물건 상세정보')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.image, size: 80, color: Colors.grey[600]),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.shopping_basket,
                    label: '물건',
                    value: item.itemName,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on,
                    label: '위치',
                    value: item.location,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: '등록일',
                    value: _formatDate(item.createdAt),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    '상세 설명',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  if (item.preferences.isNotEmpty) ...[
                    const Text(
                      '희망 사항',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.preferences,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    '요청자 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OtherUserProfileScreen(user: item.requester),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.onSurfaceVariantColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Text(
                              item.requester.name[0],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.requester.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: context.starColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.requester.score}점',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '거래 ${item.requester.dealHistory.length}건',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.onSurfaceVariantColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(rentalItem: item, otherUser: item.requester),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '채팅하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.onPrimaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 16, color: context.onSurfaceVariantColor),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.onSurfaceVariantColor,
            ),
          ),
        ),
      ],
    );
  }
}
