import 'package:flutter/material.dart';
import '/extensions/rental_status_extension.dart';
import '/extensions/theme_extension.dart';
import '/models/chatting.dart';
import '/models/rental_item.dart';
import '/widgets/widget_factory.dart';

class ChattingRoomWidgetFactory extends WidgetFactory {
  final Chatting chatting;
  final VoidCallback onTap;
  final String productName;
  final RentalStatus status;

  ChattingRoomWidgetFactory({
    required this.chatting,
    required this.onTap,
    required this.productName,
    required this.status,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final hhmm = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final isToday = now.year == time.year && now.month == time.month && now.day == time.day;
    if (isToday) return hhmm;
    return '${time.month}/${time.day} $hhmm';
  }

  @override
  Widget makeWidget(BuildContext context) {
    final lastMessageText = chatting.getLastMessageText();
    final lastMessageTime = chatting.getLastMessageTime();

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
                  chatting.opponentName.isNotEmpty ? chatting.opponentName[0] : '?',
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
                          chatting.opponentName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          productName,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.onSurfaceVariantColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessageText ?? '아직 메시지가 없습니다',
                      style: TextStyle(
                        fontSize: 13,
                        color: lastMessageText != null
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
                  if (lastMessageTime != null)
                    Text(
                      _formatTime(lastMessageTime),
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
