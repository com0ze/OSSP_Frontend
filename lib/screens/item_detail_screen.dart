import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/managers/login_manager.dart';
import '/models/match.dart';
import '/models/rental_item.dart';
import '/screens/chat_screen.dart';
import '/screens/other_user_profile_screen.dart';
import '/widgets/review_widget_factory.dart';

class ItemDetailScreen extends StatefulWidget {
  final RentalItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    DataManager dataManager = DataManager();
    return Scaffold(
      appBar: AppBar(title: const Text('물건 상세정보')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            dataManager.itemDetailScreenInitCache(widget.item.id),
          ]);
          setState(() {});
        },
        child: ListenableBuilder(
          listenable: dataManager,
          builder: (context, child) {
            final currentItem =
                dataManager.rentalItems[widget.item.id] ?? widget.item;
            final requester = dataManager.getUser(currentItem.requesterID);
            // 유저 정보 부재로 인한 이상 물건
            if (requester == null) {
              return const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '요청하신 물건 정보가 없습니다',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // // 확정된 매치에서 리뷰 조회
            // 현재는 아이템 상세 정보 화면에서 리뷰 리턴이 백에 없음
            // final currentMatch = currentItem.matchedID != null
            //     ? dataManager.matches[currentItem.matchedID!]
            //     : null;
            // final requesterReview = currentMatch?.requesterReviewID != null
            //     ? dataManager.getReviewById(currentMatch!.requesterReviewID!)
            //     : null;
            // final lenderReview = currentMatch?.lenderReviewID != null
            //     ? dataManager.getReviewById(currentMatch!.lenderReviewID!)
            //     : null;

            final requesterReview = null;
            final lenderReview = null;

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
                          currentItem.product.name,
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
                          icon: Icons.timer_outlined,
                          label: '대여 시간',
                          value: _formatDuration(currentItem.duration),
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
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OtherUserProfileScreen(user: requester),
                              ),
                            );
                            await DataManager().itemDetailScreenInitCache(
                              widget.item.id,
                            );
                            setState(() {});
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
                                            '거래 ${requester.rentalCount}건',
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
          final currentUser = LoginManager().currentUser;
          final currentItem =
              dataManager.rentalItems[widget.item.id] ?? widget.item;
          final isRequester = currentItem.requesterID == currentUser.id;

          if (isRequester) {
            final confirmedMatch = currentItem.matchedID != null
                ? dataManager.matches[currentItem.matchedID!]
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
            final match = dataManager.getMatch(widget.item.matchedID);
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
                      // 취소나 대기인 경우 채팅하기 버튼 비활성화
                      currentItem.rentalStatus == RentalStatus.cancelled ||
                          currentItem.rentalStatus == RentalStatus.pending
                      ? null
                      : _onChatPressed(
                          context,
                          currentItem,
                          match,
                          isRequester,
                        ),
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

  Future<void> _onChatPressed(
    BuildContext context,
    RentalItem currentItem,
    Match? match,
    bool isRequester,
  ) async {
    if (isRequester) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatScreen(rentalItem: currentItem, match: match!),
        ),
      );
      await DataManager().itemDetailScreenInitCache(widget.item.id);
      setState(() {});
    } else {
      Match? effectiveMatch = match;
      if (match == null) {
        // 기존에 match가 없었다면 새로운 매치 생성
        effectiveMatch = await DataManager().createMatchWithChatting(
          currentItem.id,
        );
      }
      if (effectiveMatch == null) return;
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            rentalItem: currentItem.copyWith(
              rentalStatus: RentalStatus.matchConfirmed,
            ),
            match: effectiveMatch!,
          ),
        ),
      );

      await DataManager().itemDetailScreenInitCache(widget.item.id);
      setState(() {});
    }
  }

  void _onCancelPressed(
    BuildContext context,
    RentalItem currentItem,
    Match? match,
    bool isRequester,
  ) async {
    // 1. 다이얼로그를 띄우고 유저가 '예(true)' 또는 '아니오(false)'를 누를 때까지 기다립니다.
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('취소 확인'),
        content: const Text('정말 취소하시겠습니까? 매치가 취소됩니다.'),
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
    );

    // 2. 유저가 바깥 쪽을 눌러서 닫았거나(null), '아니오(false)'를 눌렀다면 함수를 종료합니다.
    if (confirmed != true) return;

    // 3. '예'를 눌렀다면 서버에 매치 취소 요청을 보내고 완료될 때까지 기다립니다.
    await DataManager().cancelMatch(currentItem.id);

    // 4. [중요] 비동기 작업(서버 통신)이 끝났으므로, 현재 화면의 context가 살아있는지 검사합니다.
    if (!context.mounted) return;

    // 5. 매치가 성공적으로 취소되었으므로, 현재 상세 화면을 닫고 부모창(목록)으로 돌아갑니다!
    // 이때 true를 던져주면 부모창에서 목록을 새로고침(setState)하기 좋습니다.
    Navigator.pop(context, true);
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h.toString().padLeft(2, '0')}시간${m.toString().padLeft(2, '0')}분';
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
