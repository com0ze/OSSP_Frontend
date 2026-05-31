import 'package:flutter/material.dart';
import '/extensions/rental_status_extension.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/managers/login_manager.dart';
import '/models/rental_item.dart';
import '/screens/item_detail_screen.dart';
import '/screens/lender_profile_screen.dart';
import '/screens/setting_screen.dart';
import '/widgets/review_widget_factory.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LoginManager loginManager = LoginManager();
  final DataManager dataManager = DataManager();

  bool _borrowedInProgress = true;
  bool _lentInProgress = true;
  bool _showReceivedReviews = true;

  String get _currentUserId => loginManager.currentUser.id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await dataManager.userProfileScreenInitCache();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshMyData() => dataManager.userProfileScreenInitCache();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.01;

    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, child) {
        final freshUser =
            dataManager.getUser(_currentUserId) ?? loginManager.currentUser;

        final borrowedItems = dataManager.getBorrowedItems(freshUser.id);
        final lentItems = dataManager.getLentItems(freshUser.id);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimaryColor,
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
              RefreshIndicator(
                onRefresh: _refreshMyData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: UserInfoHeader(
                    user: freshUser,
                    email: LoginManager().currentUser.email,
                  ),
                ),
              ),
              const Divider(height: 1),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '빌린 물건'),
                  Tab(text: '빌려준 물건'),
                  Tab(text: '리뷰'),
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
    final reviews = _showReceivedReviews
        ? dataManager.getUserReceivedReview(_currentUserId)
        : dataManager.getUserWriteReview(_currentUserId);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 250,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('받은 리뷰')),
                  ButtonSegment(value: false, label: Text('작성한 리뷰')),
                ],
                selected: {_showReceivedReviews},
                onSelectionChanged: (val) =>
                    setState(() => _showReceivedReviews = val.first),
              ),
            ),
          ),
        ),
        if (reviews.isEmpty)
          Expanded(
            child: Center(
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
                    _showReceivedReviews ? '받은 리뷰가 없습니다' : '작성한 리뷰가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) => ReviewWidgetFactory(
                review: reviews[index],
              ).makeWidget(context),
            ),
          ),
      ],
    );
  }

  Widget _buildItemList(List<RentalItem> items, {required bool isBorrowed}) {
    final inProgress = isBorrowed ? _borrowedInProgress : _lentInProgress;

    final filteredItems = items.where((item) {
      final status = dataManager.getStatusForUserOnItem(
        item.id,
        _currentUserId,
      );
      final isActive =
          status == RentalStatus.pending ||
          status == RentalStatus.matchConfirmed ||
          status == RentalStatus.inProgress;
      return inProgress ? isActive : !isActive;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 250,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('진행 중')),
                  ButtonSegment(value: false, label: Text('거래 완료')),
                ],
                selected: {inProgress},
                onSelectionChanged: (val) => setState(() {
                  if (isBorrowed) {
                    _borrowedInProgress = val.first;
                  } else {
                    _lentInProgress = val.first;
                  }
                }),
              ),
            ),
          ),
        ),
        if (filteredItems.isEmpty)
          Expanded(
            child: Center(
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
                    inProgress
                        ? (isBorrowed ? '진행 중인 빌린 물건이 없습니다' : '진행 중인 빌려준 물건이 없습니다')
                        : (isBorrowed ? '완료된 빌린 물건이 없습니다' : '완료된 빌려준 물건이 없습니다'),
                    style: TextStyle(
                      fontSize: 16,
                      color: context.onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];

                final String? otherName;
                if (isBorrowed) {
                  final chatting = dataManager
                      .getAllChattings()
                      .where((c) => c.requestId == item.id)
                      .firstOrNull;
                  otherName = chatting?.opponentName;
                } else {
                  otherName = item.requesterName.isNotEmpty
                      ? item.requesterName
                      : null;
                }

                final status = dataManager.getStatusForUserOnItem(
                  item.id,
                  _currentUserId,
                );
                return _buildItemCard(item, otherName, status);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildItemCard(
    RentalItem item,
    String? otherName,
    RentalStatus status,
  ) {
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
                  if (otherName != null) ...[
                    CircleAvatar(
                      radius: 12,
                      child: Text(
                        otherName[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(otherName),
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
