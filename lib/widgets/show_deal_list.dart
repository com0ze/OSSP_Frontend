import 'package:flutter/material.dart';
import '../models/deal.dart';
import 'show_widget.dart';
import 'show_deal.dart';

class ShowDealList extends ShowWidget {
  final List<Deal> deals;
  final Function(Deal)? onDealTap;

  ShowDealList({
    required this.deals,
    this.onDealTap,
  });

  @override
  Widget makeWidget() {
    if (deals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '거래 내역이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final deal = deals[index];
        return ShowDeal(
          deal: deal,
          onTap: onDealTap != null ? () => onDealTap!(deal) : null,
        ).makeWidget();
      },
    );
  }
}
