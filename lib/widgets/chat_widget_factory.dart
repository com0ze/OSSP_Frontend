import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/models/chat.dart';
import '/widgets/widget_factory.dart';

class ChatWidgetFactory extends WidgetFactory {
  final Chat message;
  final String currentUserId;

  ChatWidgetFactory({required this.message, required this.currentUserId});

  @override
  Widget makeWidget(BuildContext context) {
    final isMe = message.senderId == currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        decoration: BoxDecoration(
          color: isMe ? context.primaryColor : context.tertiaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? context.onPrimaryColor : context.onTertiaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? context.onPrimaryColor.withValues(alpha: 0.5)
                    : context.onTertiaryColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final hhmm = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final isToday = now.year == dateTime.year && now.month == dateTime.month && now.day == dateTime.day;
    if (isToday) return hhmm;
    return '${dateTime.month}/${dateTime.day} $hhmm';
  }
}
