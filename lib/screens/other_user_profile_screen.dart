import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/managers/test_data_manager.dart';
import 'package:open_source_software/models/review.dart';
import 'package:open_source_software/models/user.dart';
import 'package:open_source_software/screens/lender_profile_screen.dart';
import 'package:open_source_software/widgets/review_widget_factory.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final User user;
  final DataManager dataManager = TestDataManager();

  OtherUserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final reviews = _generateReviews();

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
                      '(${reviews.length})',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (reviews.isEmpty)
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
                  ...reviews.map(
                    (review) =>
                        ReviewWidgetFactory(review: review).makeWidget(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Review> _generateReviews() {
    return dataManager.matches.values
        .map((m) {
          // 이 유저가 요청자 → 대여자가 작성한 lenderReview가 이 유저에 대한 리뷰
          if (m.requesterID == user.id && m.lenderReviewID != null) {
            return dataManager.getReviewById(m.lenderReviewID!);
          }
          // 이 유저가 대여자 → 요청자가 작성한 requesterReview가 이 유저에 대한 리뷰
          if (m.lenderID == user.id && m.requesterReviewID != null) {
            return dataManager.getReviewById(m.requesterReviewID!);
          }
          return null;
        })
        .whereType<Review>()
        .toList();
  }
}
