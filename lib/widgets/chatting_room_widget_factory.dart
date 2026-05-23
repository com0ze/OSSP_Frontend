import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/rental_status_extension.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/managers/test_data_manager.dart';
import 'package:open_source_software/models/chat.dart';
import 'package:open_source_software/models/match.dart';
import 'package:open_source_software/widgets/widget_factory.dart';

class ChattingRoomWidgetFactory extends WidgetFactory {
  final Match match;
  final VoidCallback onTap;

  ChattingRoomWidgetFactory({required this.match, required this.onTap});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.month}/${time.day}';
  }

  @override
  Widget makeWidget(BuildContext context) {
    final testDataManager = TestDataManager();
    final loginManager = LoginManager();

    final currentUserId = loginManager.currentUserOrGuest.id;
    final otherUserId = match.requesterID == currentUserId
        ? match.lenderID
        : match.requesterID;
    final otherUser = testDataManager.getUserById(otherUserId);
    final item = testDataManager.rentalItems[match.rentalItemID];
    final Chat? lastChat =
        testDataManager.getChattingById(match.chattingID)?.getLastChat();
    final status = testDataManager.getStatusForUserOnItem(
      match.rentalItemID,
      currentUserId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  otherUser.name[0],
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          otherUser.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item?.product.name ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.onSurfaceVariantColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastChat?.chatText ?? '아직 메시지가 없습니다',
                      style: TextStyle(
                        fontSize: 13,
                        color: lastChat != null
                            ? context.onSurfaceColor
                            : context.onSurfaceVariantColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (lastChat != null)
                    Text(
                      _formatTime(lastChat.sendTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.onSurfaceVariantColor,
                      ),
                    ),
                  const SizedBox(height: 6),
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
                        fontSize: 11,
                        color: status.color,
                        fontWeight: FontWeight.bold,
                      ),
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
