import 'package:flutter/material.dart';
import '../models/rental_item.dart';
import '../models/user.dart';
import '../models/chat_message.dart';
import 'review_screen.dart';

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
  final List<ChatMessage> _messages = [];
  late RentalStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.rentalItem.status;
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: widget.otherUser.id,
        message: '안녕하세요! ${widget.rentalItem.itemName} 관련해서 문의드립니다.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: '2',
        senderId: 'current',
        message: '네, 말씀하세요!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
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

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'current',
        message: _messageController.text,
        timestamp: DateTime.now(),
      ));
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
        return;
    }

    setState(() {
      _currentStatus = nextStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('상태가 ${_getStatusText(nextStatus)}(으)로 변경되었습니다'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getStatusText(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return '대기 중';
      case RentalStatus.matchConfirmed:
        return '매칭 확정';
      case RentalStatus.inProgress:
        return '대여 중';
      case RentalStatus.returned:
        return '반납 완료';
      case RentalStatus.reviewed:
        return '리뷰 완료';
    }
  }

  String _getNextButtonText() {
    switch (_currentStatus) {
      case RentalStatus.pending:
        return '매칭 확정';
      case RentalStatus.matchConfirmed:
        return '대여 시작';
      case RentalStatus.inProgress:
        return '반납 완료';
      case RentalStatus.returned:
        return '리뷰 작성';
      case RentalStatus.reviewed:
        return '완료됨';
    }
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case RentalStatus.pending:
        return Colors.grey;
      case RentalStatus.matchConfirmed:
        return Colors.blue;
      case RentalStatus.inProgress:
        return Colors.orange;
      case RentalStatus.returned:
        return Colors.green;
      case RentalStatus.reviewed:
        return Colors.purple;
    }
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
            color: _getStatusColor().withOpacity(0.1),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor()),
                const SizedBox(width: 8),
                Text(
                  '현재 상태: ${_getStatusText(_currentStatus)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
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
                final isMe = message.senderId == 'current';

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.message,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_currentStatus != RentalStatus.reviewed)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _updateRentalStatus,
                      icon: Icon(_getNextStatusIcon()),
                      label: Text(_getNextButtonText()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
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
                        color: Colors.blue,
                        iconSize: 28,
                      ),
                    ],
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
