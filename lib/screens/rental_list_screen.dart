import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/managers/login_manager.dart';
import '/models/rental_item.dart';
import '/screens/item_detail_screen.dart';
import '/widgets/rental_item_widget_factory.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  final DataManager dataManager = DataManager();
  final LoginManager loginManager = LoginManager();

  @override
  void initState() {
    super.initState();

    // ⭐️ 화면 렌더링 프레임이 끝난 직후(화면이 안전하게 켜진 직후) 딱 한 번 비동기 함수를 실행함
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DataManager().rentalListScreenInitCache(); // 비동기 초기화 실행
      setState(() {}); // 데이터 가져온 후 화면 딱 한 번만 갱신
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, child) {
        final currentUser = loginManager.currentUser;
        // 데이터 필터링 안 해도 이미 원하는 데이터 만 있는 상황이나
        // 혹시 모를 오류 방지를 위해서 남겨놓음
        final rentalItems = dataManager.rentalItems.values
            .where(
              (item) => !item.isMatched && item.requesterID != currentUser.id,
            )
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('대여 가능한 물건'),
            centerTitle: true,
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimaryColor,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await dataManager.rentalListScreenInitCache();
              setState(() {});
            },
            child: rentalItems.isEmpty
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
                              '현재 대여 요청이 없습니다',
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
                    itemCount: rentalItems.length,
                    itemBuilder: (context, index) {
                      final item = rentalItems[index];
                      return RentalItemWidgetFactory(
                        item: item,
                        onTap: () async {
                          // item detail screen은 stateless이므로
                          // 표시할 아이템의 정보를 미리 구해서 전송
                          final RentalItem? updatedItem = await dataManager
                              .getRentalItem(item.id);
                          if (!context.mounted) {
                            return; // 비동기 작업 후 context가 유효한지 안전하게 검사
                          }
                          if (updatedItem == null) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemDetailScreen(item: updatedItem),
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
