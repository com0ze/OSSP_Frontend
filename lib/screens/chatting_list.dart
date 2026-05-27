import 'package:flutter/material.dart';
import 'package:open_source_software/models/rental_status.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/managers/login_manager.dart';
import '/screens/chat_screen.dart';
import '/widgets/chatting_room_widget_factory.dart';

class ChattingListScreen extends StatefulWidget {
  const ChattingListScreen({super.key});

  @override
  State<ChattingListScreen> createState() => _ChattingListScreenState();
}

class _ChattingListScreenState extends State<ChattingListScreen> {
  final DataManager dataManager = DataManager();
  final LoginManager loginManager = LoginManager();

  @override
  void initState() {
    super.initState();

    // ⭐️ 화면 렌더링 프레임이 끝난 직후(화면이 안전하게 켜진 직후) 딱 한 번 비동기 함수를 실행함
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DataManager().chattingListScreenInitCache(); // 비동기 초기화 실행
      setState(() {}); // 데이터 가져온 후 화면 딱 한 번만 갱신
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, child) {
        final chattings = dataManager.getAllChattings()
          ..sort((a, b) {
            final aTime = a.getLastMessageTime();
            final bTime = b.getLastMessageTime();
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

        return Scaffold(
          appBar: AppBar(
            title: const Text('내 채팅'),
            centerTitle: true,
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimaryColor,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await dataManager.chattingListScreenInitCache();
              setState(() {});
            },
            child: chattings.isEmpty
                ? const SingleChildScrollView(
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
                              '채팅이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: chattings.length,
                    itemBuilder: (context, index) {
                      final chatting = chattings[index];
                      final match = dataManager.getMatch(chatting.matchId);
                      final rentalItem =
                          dataManager.getCachedRentalItem(chatting.requestId);
                      return ChattingRoomWidgetFactory(
                        productName: rentalItem?.product.name ?? "unknown",
                        status:
                            rentalItem?.rentalStatus ?? RentalStatus.pending,
                        chatting: chatting,
                        onTap: () async {
                          if (match == null || rentalItem == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                rentalItem: rentalItem,
                                match: match,
                              ),
                            ),
                          );
                          // 다시 화면으로 돌아올 때 데이터 초기화
                          await dataManager.rentalListScreenInitCache();
                          setState(() {});
                        },
                      ).makeWidget(context);
                    },
                  ),
          ),
        );
      },
    );
  }
}
