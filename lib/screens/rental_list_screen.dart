import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/managers/login_manager.dart';
import '/models/rental_item.dart';
import '/screens/item_detail_screen.dart';
import '/managers/location_manager.dart';
import '/widgets/location_refresh_button.dart';
import '/widgets/rental_item_widget_factory.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  final DataManager dataManager = DataManager();
  final LoginManager loginManager = LoginManager();
  String? _lastBuilding;
  late bool _isOnDuty;

  Future<void> _toggleDuty(bool value) async {
    setState(() => _isOnDuty = value);
    try {
      await LoginManager().updateDutyStatus(value);
    } catch (_) {
      // 실패 시 롤백
      if (mounted) setState(() => _isOnDuty = !value);
    }
    if (_isOnDuty) {
      try {
        await DataManager().rentalListScreenInitCache(); // 비동기 초기화 실행
      } catch (_) {
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _lastBuilding = LocationManager().currentBuildingName;
    _isOnDuty = LoginManager().currentUser.isOnDuty;
    LocationManager().addListener(_onLocationChanged);

    // ⭐️ 화면 렌더링 프레임이 끝난 직후(화면이 안전하게 켜진 직후) 딱 한 번 비동기 함수를 실행함
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isOnDuty) {
        await DataManager().rentalListScreenInitCache(); // 비동기 초기화 실행
      }
      setState(() {}); // 데이터 가져온 후 화면 딱 한 번만 갱신
    });
  }

  void _onLocationChanged() {
    final newBuilding = LocationManager().currentBuildingName;
    if (newBuilding == _lastBuilding) return;
    _lastBuilding = newBuilding;
    _refetch();
  }

  Future<void> _refetch() async {
    await DataManager().rentalListScreenInitCache();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    LocationManager().removeListener(_onLocationChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, child) {
        final currentUser = loginManager.currentUser;
        final rentalItems = dataManager.getAvailableRentalItems(currentUser.id);
        return Scaffold(
          appBar: AppBar(
            title: const Text('대여 목록'),
            centerTitle: true,
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimaryColor,
            actions: const [LocationRefreshButton(), SizedBox(width: 8)],
          ),
          body: Column(
            children: [
              ListTile(
                leading: Icon(Icons.work_outline, color: context.primaryColor),
                title: const Text('당직 설정'),
                subtitle: const Text('당직 중일 때 주변 대여 요청 알림을 받습니다.'),
                trailing: Switch(value: _isOnDuty, onChanged: _toggleDuty),
              ),
              const Divider(height: 1),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await dataManager.rentalListScreenInitCache();
                    setState(() {});
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (rentalItems.isEmpty || !_isOnDuty)
                        SizedBox(
                          height: 400,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  '현재 대여 요청이 없습니다\n장소와 당직 설정을 확인해주세요',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...rentalItems.map((item) {
                          return RentalItemWidgetFactory(
                            item: item,
                            onTap: () async {
                              final RentalItem? updatedItem = await dataManager
                                  .getRentalItem(item.id);
                              if (!context.mounted) return;
                              if (updatedItem == null) return;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemDetailScreen(item: updatedItem),
                                ),
                              );
                              await dataManager.rentalListScreenInitCache();
                              setState(() {});
                            },
                          ).makeWidget(context);
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
