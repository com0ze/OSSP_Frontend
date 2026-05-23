import 'package:flutter/material.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/managers/test_data_manager.dart';
import 'package:open_source_software/screens/item_detail_screen.dart';
import 'package:open_source_software/widgets/rental_item_widget_factory.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  final DataManager dataManager = TestDataManager();
  final LoginManager loginManager = LoginManager();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TestDataManager(),
      builder: (context, child) {
        final currentUser = loginManager.currentUserOrGuest;
        final rentalItems = dataManager.rentalItems.values
            .where(
              (item) => !item.isMatched && item.requesterID != currentUser.id,
            )
            .toList();
        return Scaffold(
          appBar: AppBar(title: const Text('대여 가능한 물건'), centerTitle: true),
          body: rentalItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '현재 대여 요청이 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rentalItems.length,
                  itemBuilder: (context, index) {
                    final item = rentalItems[index];
                    return RentalItemWidgetFactory(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailScreen(item: item),
                          ),
                        );
                      },
                    ).makeWidget(context);
                  },
                ),
        );
      },
    );
  }
}
