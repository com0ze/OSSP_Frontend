import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/rental_status_extension.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/managers/test_data_manager.dart';
import 'package:open_source_software/models/rental_item.dart';
import 'package:open_source_software/models/review.dart';
import 'package:open_source_software/models/user.dart';
import 'package:open_source_software/screens/item_detail_screen.dart';
import 'package:open_source_software/screens/lender_profile_screen.dart';
import 'package:open_source_software/screens/setting_screen.dart';
import 'package:open_source_software/widgets/review_widget_factory.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LoginManager loginManager = LoginManager();
  final DataManager dataManager = TestDataManager();
  final User _currentUser = LoginManager().currentUserOrGuest;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.01;

    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, child) {
        final borrowedItems = dataManager.requestRentalItems(_currentUser);
        final lentItems = dataManager.lentRentalItems(_currentUser);

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
                  Tab(text: '받은 리뷰'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildItemList(borrowedItems, isBorrowed: true),
                    _buildItemList(lentItems, isBorrowed: false),
                    _buildReviews(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviews() {
    List<Review> reviews = dataManager.matches.values
        .map((m) {
          // 이 유저가 요청자 → 대여자가 작성한 lenderReview가 이 유저에 대한 리뷰
          if (m.requesterID == _currentUser.id && m.lenderReviewID != null) {
            return dataManager.getReviewById(m.lenderReviewID!);
          }
          // 이 유저가 대여자 → 요청자가 작성한 requesterReview가 이 유저에 대한 리뷰
          if (m.lenderID == _currentUser.id && m.requesterReviewID != null) {
            return dataManager.getReviewById(m.requesterReviewID!);
          }
          return null;
        })
        .whereType<Review>()
        .toList();

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review,
              size: 64,
              color: context.onSurfaceVariantColor,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 리뷰가 없습니다',
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
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewWidgetFactory(review: review).makeWidget(context);
      },
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

        // 빌린 물건: 매칭 확정된 경우에만 상대방(대여자) 정보 표시
        final User? otherUser;
        if (isBorrowed) {
          final lenderId = dataManager.getMatchedLenderIdForItem(item.id);
          otherUser = lenderId != null
              ? dataManager.getUserById(lenderId)
              : null;
        } else {
          otherUser = dataManager.getUserById(item.requesterID);
        }

        final status = dataManager.getStatusForUserOnItem(
          item.id,
          _currentUser.id,
        );

        return _buildItemCard(item, otherUser, status);
      },
    );
  }

  Widget _buildItemCard(RentalItem item, User? otherUser, RentalStatus status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(item: item),
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
                      item.product.name,
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
                      color: status.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: status.color,
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
                  if (otherUser != null) ...[
                    CircleAvatar(
                      radius: 12,
                      child: Text(
                        otherUser.name[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(otherUser.name),
                  ] else
                    Text(
                      '매칭 대기 중',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.onSurfaceVariantColor,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
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
  }
}
