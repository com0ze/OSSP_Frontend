import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/managers/test_data_manager.dart';
import 'package:open_source_software/models/review.dart';
import 'package:open_source_software/models/user.dart';
import 'package:open_source_software/screens/lender_profile_screen.dart';
import 'package:open_source_software/widgets/review_widget_factory.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final User user;

  const OtherUserProfileScreen({super.key, required this.user});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  final DataManager dataManager = TestDataManager();

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 해당 유저의 최신 정보와 리뷰를 서버에서 갱신
    dataManager.fetchUserProfile(widget.user.id).ignore();
  }

  List<Review> _generateReviews() {
    return dataManager.matches.values
        .map((m) {
          if (m.requesterID == widget.user.id && m.lenderReviewID != null) {
            return dataManager.getReviewById(m.lenderReviewID!);
          }
          if (m.lenderID == widget.user.id && m.requesterReviewID != null) {
            return dataManager.getReviewById(m.requesterReviewID!);
          }
          return null;
        })
        .whereType<Review>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, _) {
        // 캐시에서 최신 유저 정보 조회
        final freshUser = dataManager.getUserById(widget.user.id);
        final reviews = _generateReviews();

        return Scaffold(
          appBar: AppBar(title: const Text('사용자 정보')),
          body: RefreshIndicator(
            onRefresh: () => dataManager.fetchUserProfile(widget.user.id),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                UserInfoHeader(user: freshUser),
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
                          (review) => ReviewWidgetFactory(
                            review: review,
                          ).makeWidget(context),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
