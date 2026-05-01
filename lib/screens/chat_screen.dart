import 'package:flutter/material.dart';
import '../models/rental_item.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../extensions/rental_status_extension.dart';
import 'review_screen.dart';
import 'package:open_source_software/extensions/theme_extension.dart';

class ChatScreen extends StatefulWidget {
  final RentalItem rentalItem;
  final User otherUser;

  const ChatScreen({
    super.key,
    required this.rentalItem,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Chat> _messages = [];
  late RentalStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.rentalItem.status;
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    // 현재 사용자를 위한 임시 User 객체
    final currentUser = User(id: 'current', name: '나', email: '');

    _messages.addAll([
      Chat(
        id: '1',
        sendUser: widget.otherUser,
        chatText: '안녕하세요! ${widget.rentalItem.itemName} 관련해서 문의드립니다.',
        sendTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Chat(
        id: '2',
        sendUser: currentUser,
        chatText: '네, 말씀하세요!',
        sendTime: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 55),
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = User(id: 'current', name: '나', email: '');

    setState(() {
      _messages.add(
        Chat(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sendUser: currentUser,
          chatText: _messageController.text,
          sendTime: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
  }

  void _updateRentalStatus() {
    RentalStatus nextStatus;

    switch (_currentStatus) {
      case RentalStatus.pending:
        nextStatus = RentalStatus.matchConfirmed;
        break;
      case RentalStatus.matchConfirmed:
        nextStatus = RentalStatus.inProgress;
        break;
      case RentalStatus.inProgress:
        nextStatus = RentalStatus.returned;
        break;
      case RentalStatus.returned:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewScreen(
              rentalItem: widget.rentalItem,
              reviewee: widget.otherUser,
            ),
          ),
        );
        return;
      case RentalStatus.reviewed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text(
              '이미 리뷰가 완료된 상태입니다',
              style: TextStyle(color: context.onSurfaceColor),
            ),
            backgroundColor: context.warningColor.withValues(alpha: 0.8),
          ),
        );
        return;
    }

    setState(() {
      _currentStatus = nextStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 500),
        content: Text(
          '상태가 ${nextStatus.text}(으)로 변경되었습니다',
          style: TextStyle(color: context.onSurfaceColor),
        ),
        backgroundColor: nextStatus.color.withValues(alpha: 0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUser.name),
            Text(
              widget.rentalItem.itemName,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: _currentStatus.color.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _currentStatus.color),
                const SizedBox(width: 8),
                Text(
                  '현재 상태: ${_currentStatus.text}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _currentStatus.color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.sendUser.id == 'current';

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? context.primaryColor
                          : context.tertiaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.chatText,
                          style: TextStyle(
                            color: isMe
                                ? context.onPrimaryColor
                                : context.onTertiaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.sendTime),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? context.onPrimaryColor.withValues(alpha: 0.5)
                                : context.onTertiaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updateRentalStatus,
                  icon: Icon(_getNextStatusIcon()),
                  label: Text(_currentStatus.nextButtonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStatus == RentalStatus.pending
                        ? RentalStatus.matchConfirmed.color
                        : _currentStatus == RentalStatus.matchConfirmed
                        ? RentalStatus.inProgress.color
                        : _currentStatus == RentalStatus.inProgress
                        ? RentalStatus.returned.color
                        : _currentStatus == RentalStatus.returned
                        ? RentalStatus.reviewed.color
                        : Colors.grey,
                    foregroundColor: context.onSurfaceColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: context.primaryColor,
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case RentalStatus.pending:
        return Icons.hourglass_empty;
      case RentalStatus.matchConfirmed:
        return Icons.check_circle;
      case RentalStatus.inProgress:
        return Icons.sync;
      case RentalStatus.returned:
        return Icons.assignment_turned_in;
      case RentalStatus.reviewed:
        return Icons.star;
    }
  }

  IconData _getNextStatusIcon() {
    switch (_currentStatus) {
      case RentalStatus.pending:
        return Icons.handshake;
      case RentalStatus.matchConfirmed:
        return Icons.play_arrow;
      case RentalStatus.inProgress:
        return Icons.check;
      case RentalStatus.returned:
        return Icons.rate_review;
      case RentalStatus.reviewed:
        return Icons.done_all;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
