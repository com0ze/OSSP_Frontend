import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/models/user.dart';
import '/screens/lender_profile_screen.dart';
import '/widgets/review_widget_factory.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final User user;

  const OtherUserProfileScreen({super.key, required this.user});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  final DataManager dataManager = DataManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DataManager().otherUserProfileScreenInitCache(
        widget.user.id,
      ); // 비동기 초기화 실행
      setState(() {}); // 데이터 가져온 후 화면 딱 한 번만 갱신
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, _) {
        // 캐시에서 최신 유저 정보 조회
        final freshUser = dataManager.getUser(widget.user.id)!;
        final reviews = DataManager().getUserReceivedReview(widget.user.id);

        return Scaffold(
          appBar: AppBar(
            title: const Text('사용자 정보'),
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimaryColor,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await dataManager.otherUserProfileScreenInitCache(widget.user.id);
            },
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
