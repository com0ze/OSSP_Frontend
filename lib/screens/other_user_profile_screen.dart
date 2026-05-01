import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/review.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'lender_profile_screen.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final User user;

  const OtherUserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final sampleReviews = _generateSampleReviews();

    return Scaffold(
      appBar: AppBar(title: const Text('사용자 정보')),
      body: ListView(
        children: [
          UserInfoHeader(user: user),
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
                      style: TextStyle(
                        fontSize: 16,
                        color: context.onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (sampleReviews.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review,
                            size: 48,
                            color: context.onSurfaceVariantColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '아직 리뷰가 없습니다',
                            style: TextStyle(
                              color: context.onSurfaceVariantColor,
                            ),
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
        score: 5,
        reviewText: '매우 친절하시고 물건 상태도 좋았습니다. 감사합니다!',
        writer: User(
          id: 'reviewer1',
          name: '김리뷰',
          email: 'reviewer1@example.com',
          score: 85,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Review(
        id: '2',
        score: 4,
        reviewText: '약속 시간도 잘 지키시고 좋았어요.',
        writer: User(
          id: 'reviewer2',
          name: '이후기',
          email: 'reviewer2@example.com',
          score: 90,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Review(
        id: '3',
        score: 4,
        reviewText: '대여 과정이 원활했습니다.',
        writer: User(
          id: 'reviewer3',
          name: '박평가',
          email: 'reviewer3@example.com',
          score: 75,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
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
                Text(
                  review.writer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < review.score ? Icons.star : Icons.star_border,
                    color: context.starColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${review.score}점',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatDate(review.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.reviewText,
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
