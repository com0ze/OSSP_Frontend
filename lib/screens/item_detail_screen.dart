import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/models/match.dart';
import 'package:open_source_software/models/rental_item.dart';
import 'package:open_source_software/screens/chat_screen.dart';
import 'package:open_source_software/screens/other_user_profile_screen.dart';
import 'package:open_source_software/widgets/review_widget_factory.dart';

class ItemDetailScreen extends StatelessWidget {
  final RentalItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    DataManager dataManager = DataManager();
    return Scaffold(
      appBar: AppBar(title: const Text('물건 상세정보')),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          dataManager.fetchAvailableRentalItems(
            LoginManager().currentUserOrGuest.id,
          ),
          dataManager.fetchUserProfile(item.requesterID),
        ]),
        child: ListenableBuilder(
          listenable: dataManager,
          builder: (context, child) {
            final currentItem = dataManager.rentalItems[item.id] ?? item;
            final requester = dataManager.getUserById(currentItem.requesterID);

            // 확정된 매치에서 리뷰 조회
            final currentMatch = currentItem.matchedID != null
                ? dataManager.matches[currentItem.matchedID!]
                : null;
            final requesterReview = currentMatch?.requesterReviewID != null
                ? dataManager.getReviewById(currentMatch!.requesterReviewID!)
                : null;
            final lenderReview = currentMatch?.lenderReviewID != null
                ? dataManager.getReviewById(currentMatch!.lenderReviewID!)
                : null;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentItem.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currentItem.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
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
                          value: currentItem.product.name,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.location_on,
                          label: '위치',
                          value:
                              DataManager.placeById(
                                currentItem.placeID,
                              )?.name ??
                              currentItem.placeID,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: '등록일',
                          value: _formatDate(currentItem.createdAt),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          '상세 설명',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentItem.description,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        if (currentItem.preferences.isNotEmpty) ...[
                          const Text(
                            '희망 사항',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentItem.preferences,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          '요청자 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OtherUserProfileScreen(user: requester),
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
                                    requester.name[0],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        requester.name,
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
                                            '${requester.score}점',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '거래 ${requester.rentalHistory.length}건',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  context.onSurfaceVariantColor,
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
                        if (requesterReview != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            '요청자 리뷰',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ReviewWidgetFactory(
                            review: requesterReview,
                          ).makeWidget(context),
                        ],
                        if (lenderReview != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            '대여자 리뷰',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ReviewWidgetFactory(
                            review: lenderReview,
                          ).makeWidget(context),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: dataManager,
        builder: (context, _) {
          final tdm = dataManager;
          final currentUser = LoginManager().currentUserOrGuest;
          final currentItem = tdm.rentalItems[item.id] ?? item;
          final isRequester = currentItem.requesterID == currentUser.id;

          if (isRequester) {
            final confirmedMatch = currentItem.matchedID != null
                ? tdm.matches[currentItem.matchedID!]
                : null;
            // 아이템이 실제로 대여 전 상태일 때만 취소 버튼 표시
            final isPreRental =
                currentItem.rentalStatus == RentalStatus.pending ||
                currentItem.rentalStatus == RentalStatus.matchConfirmed;
            return _buildBottomBar(
              context,
              currentItem: currentItem,
              match: confirmedMatch,
              showChat: confirmedMatch != null,
              showCancel: isPreRental,
              isRequester: true,
            );
          } else {
            final match = tdm.findMatch(item.id, currentUser.id);
            // 이 대여자가 현재 확정된 대여자일 때만 취소 버튼 표시
            final isConfirmedLender =
                match != null && currentItem.matchedID == match.matchID;
            final isPreRental =
                isConfirmedLender &&
                (currentItem.rentalStatus == RentalStatus.pending ||
                    currentItem.rentalStatus == RentalStatus.matchConfirmed);
            return _buildBottomBar(
              context,
              currentItem: currentItem,
              match: match,
              showChat: true,
              showCancel: isPreRental,
              isRequester: false,
            );
          }
        },
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context, {
    required RentalItem currentItem,
    required Match? match,
    required bool showChat,
    required bool showCancel,
    required bool isRequester,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showChat)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      _onChatPressed(context, currentItem, match, isRequester),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '채팅하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (showCancel) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _onCancelPressed(
                    context,
                    currentItem,
                    match,
                    isRequester,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '취소하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onChatPressed(
    BuildContext context,
    RentalItem currentItem,
    Match? match,
    bool isRequester,
  ) {
    if (isRequester) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatScreen(rentalItem: currentItem, match: match!),
        ),
      );
    } else {
      final effectiveMatch =
          match ??
          DataManager().createMatchWithChatting(
            currentItem.id,
            LoginManager().currentUserOrGuest.id,
          );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatScreen(rentalItem: currentItem, match: effectiveMatch),
        ),
      );
    }
  }

  void _onCancelPressed(
    BuildContext context,
    RentalItem currentItem,
    Match? match,
    bool isRequester,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('취소 확인'),
        content: Text(
          isRequester
              ? '정말 취소하시겠습니까? 모든 매치가 취소됩니다.'
              : '정말 취소하시겠습니까? 매칭이 취소되고 아이템은 다시 대기 상태가 됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('예', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true) return;
      if (isRequester) {
        DataManager().cancelAllMatchesForItem(currentItem.id);
      } else if (match != null) {
        DataManager().cancelLenderMatch(match.matchID);
      }
    });
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
