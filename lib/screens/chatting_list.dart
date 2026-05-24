import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, child) {
        final currentUser = loginManager.currentUserOrGuest;
        final matches = dataManager.matches.values
            .where(
              (m) =>
                  m.requesterID == currentUser.id ||
                  m.lenderID == currentUser.id,
            )
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('내 채팅'),
            centerTitle: true,
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimaryColor,
          ),
          body: RefreshIndicator(
            onRefresh: () => dataManager.fetchMyData(currentUser.id),
            child: matches.isEmpty
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
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      final rentalItem =
                          dataManager.rentalItems[match.rentalItemID];
                      return ChattingRoomWidgetFactory(
                        match: match,
                        onTap: () {
                          if (rentalItem == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                rentalItem: rentalItem,
                                match: match,
                              ),
                            ),
                          );
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
