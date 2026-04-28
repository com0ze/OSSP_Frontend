import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/review.dart';

class LenderProfileScreen extends StatelessWidget {
  final User user;

  const LenderProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final sampleReviews = _generateSampleReviews();

    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 정보'),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    user.name[0],
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 4),
                    Text(
                      user.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      label: '대여한 물건',
                      value: user.totalRentals.toString(),
                      icon: Icons.shopping_bag_outlined,
                    ),
                    _StatCard(
                      label: '빌려준 물건',
                      value: user.totalLends.toString(),
                      icon: Icons.local_offer_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '리뷰',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${sampleReviews.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (sampleReviews.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.rate_review, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            '아직 리뷰가 없습니다',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...sampleReviews.map((review) => _ReviewCard(review: review)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Review> _generateSampleReviews() {
    return [
      Review(
        id: '1',
        rentalItemId: 'item1',
        reviewerId: 'reviewer1',
        revieweeId: user.id,
        rating: 5.0,
        comment: '매우 친절하시고 물건 상태도 좋았습니다. 감사합니다!',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Review(
        id: '2',
        rentalItemId: 'item2',
        reviewerId: 'reviewer2',
        revieweeId: user.id,
        rating: 4.5,
        comment: '약속 시간도 잘 지키시고 좋았어요.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Review(
        id: '3',
        rentalItemId: 'item3',
        reviewerId: 'reviewer3',
        revieweeId: user.id,
        rating: 4.0,
        comment: '대여 과정이 원활했습니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(height: 8),
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
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating.floor()
                        ? Icons.star
                        : (index < review.rating ? Icons.star_half : Icons.star_border),
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(review.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
