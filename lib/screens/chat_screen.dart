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
  final List<Chat> _pendingMessages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isReadingPastMessages = false;
  late RentalStatus _currentStatus;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // 바닥에서 100픽셀 이상 올라가면 '과거를 읽고 있다'고 판단
      bool isPast = _scrollController.offset > 100;
      if (isPast != _isReadingPastMessages) {
        setState(() {
          _isReadingPastMessages = isPast;
        });
      }

      // 만약 수동으로 다시 맨 아래로 스크롤을 내렸다면? 대기열의 메시지를 방출!
      if (_scrollController.offset <= 10 && _pendingMessages.isNotEmpty) {
        _releasePendingMessages();
      }
    });

    _currentStatus = widget.rentalItem.status;
    _loadSampleMessages();
  }

  void _releasePendingMessages() {
    setState(() {
      for (var msg in _pendingMessages) {
        _messages.add(msg);
      }
      _pendingMessages.clear();
    });
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

  // TODO: 실제 메시지 수신 로직이 구현되면 이 부분을 새로운 메시지를 처리하도록 합니다.
  void _receiveMessage(Chat message) {
    setState(() {
      if (_isReadingPastMessages) {
        // 과거 메시지를 읽는 중이라면 대기열에 추가
        _pendingMessages.add(message);
      } else {
        // 그렇지 않다면 바로 메시지 목록에 추가
        _messages.add(message);
      }
    });
    _messageController.clear();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = User(id: 'current', name: '나', email: '');

    setState(() {
      _releasePendingMessages(); // 새 메시지를 보내기 전에 대기열에 있는 메시지를 먼저 방출
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 스크롤 뷰가 정상적으로 연결되어 있는지 한 번 더 안전하게 확인
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
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
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      final isMe = message.sendUser.id == 'current';

                      return _buildChatBubble(message, isMe);
                    },
                  ),
                ),
                if (_pendingMessages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          _releasePendingMessages(); // 메시지 방출
                          // 덤으로 맨 아래로 스르륵 내려가게 해줍니다.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // 3. 스크롤 뷰가 정상적으로 연결되어 있는지 한 번 더 안전하게 확인
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                              );
                            }
                          });
                        },
                        label: Text('${_pendingMessages.length}개의 새 메시지'),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
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
                          // 테스트용으로 상대방 메시지 수신을 시뮬레이션하는 구문
                          // 엔터를 치면 상대방이 메시지를 보내는 것으로 간주합니다.
                          // 실제 구현에서는 다음 줄로 넘어가게 구현해야하니
                          // 이 부분은 나중에 삭제해주세요!
                          //----------------------------------------------------
                          onSubmitted: (_) => _receiveMessage(
                            Chat(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              sendUser: widget.otherUser,
                              chatText: _messageController.text,
                              sendTime: DateTime.now(),
                            ),
                          ),
                          //----------------------------------------------------
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

  Align _buildChatBubble(Chat message, bool isMe) {
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
              message.chatText,
              style: TextStyle(
                color: isMe ? context.onPrimaryColor : context.onTertiaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.sendTime),
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
}
