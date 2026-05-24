import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'package:open_source_software/managers/test_data_manager.dart';
import 'package:open_source_software/models/rental_item.dart';
import 'package:open_source_software/widgets/widget_factory.dart';

class RentalItemWidgetFactory extends WidgetFactory {
  final RentalItem item;
  final VoidCallback onTap;

  RentalItemWidgetFactory({required this.item, required this.onTap});

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  @override
  Widget makeWidget(BuildContext context) {
    final dataManager = TestDataManager();
    final requester = dataManager.getUserById(item.requesterID);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _getTimeAgo(item.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.shopping_basket,
                    size: 16,
                    color: context.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: context.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(TestDataManager.placeById(item.placeID)?.name ?? item.placeID),
                  const Spacer(),
                  Text(
                    '${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.onSurfaceVariantColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    child: Text(
                      requester.name[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(requester.name, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Icon(Icons.star, size: 14, color: context.starColor),
                  const SizedBox(width: 2),
                  Text(
                    '${requester.score}점',
                    style: const TextStyle(fontSize: 14),
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
