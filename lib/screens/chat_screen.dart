import 'package:flutter/material.dart';
import '/extensions/rental_status_extension.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/managers/login_manager.dart';
import '/models/chat.dart';
import '/models/match.dart';
import '/models/rental_item.dart';
import '/models/user.dart';
import '/screens/item_detail_screen.dart';
import '/screens/review_screen.dart';
import '/widgets/chat_widget_factory.dart';

class ChatScreen extends StatefulWidget {
  final RentalItem rentalItem;
  final Match match;

  const ChatScreen({super.key, required this.rentalItem, required this.match});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Chat> _messages = [];
  final List<Chat> _pendingMessages = [];
  final ScrollController _scrollController = ScrollController();
  final LoginManager loginManager = LoginManager();
  final DataManager dataManager = DataManager();
  bool _isReadingPastMessages = false;
  late RentalStatus _currentStatus;
  late User _otherUser;
  int _syncedCount = 0;

  @override
  void initState() {
    super.initState();

    _currentStatus = dataManager.getStatusForUserOnItem(
      widget.rentalItem.id,
      loginManager.currentUserOrGuest.id,
    );

    final currentUserId = loginManager.currentUserOrGuest.id;
    final otherUserId = widget.match.requesterID == currentUserId
        ? widget.match.lenderID
        : widget.match.requesterID;
    _otherUser = dataManager.getUserById(otherUserId);

    _scrollController.addListener(() {
      bool isPast = _scrollController.offset > 100;
      if (isPast != _isReadingPastMessages) {
        setState(() => _isReadingPastMessages = isPast);
      }
      if (_scrollController.offset <= 10 && _pendingMessages.isNotEmpty) {
        _releasePendingMessages();
      }
    });

    _loadMessages();
    dataManager.addListener(_onDataChanged);
    // 화면 진입 시 최신 메시지 서버에서 갱신 (_syncFromChatting이 새 메시지를 자동 반영)
    dataManager.fetchChatMessages(widget.match.chattingID);
  }

  @override
  void dispose() {
    dataManager.removeListener(_onDataChanged);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _syncFromChatting();
  }

  void _loadMessages() {
    final chatting = dataManager.getChattingById(widget.match.chattingID);
    if (chatting == null) return;
    _messages.addAll(chatting.chats);
    _syncedCount = chatting.chats.length;
  }

  Future<void> _refreshMessages() async {
    await dataManager.fetchChatMessages(widget.match.chattingID);
    if (!mounted) return;
    final chatting = dataManager.getChattingById(widget.match.chattingID);
    if (chatting == null) return;
    setState(() {
      _messages.clear();
      _pendingMessages.clear();
      _messages.addAll(chatting.chats);
      _syncedCount = chatting.chats.length;
    });
  }

  void _syncFromChatting() {
    if (!mounted) return;
    final latestStatus = dataManager.getStatusForUserOnItem(
      widget.rentalItem.id,
      loginManager.currentUserOrGuest.id,
    );
    if (latestStatus != _currentStatus) {
      setState(() => _currentStatus = latestStatus);
    }
    final chatting = dataManager.getChattingById(widget.match.chattingID);
    if (chatting == null) return;
    final chats = chatting.chats;
    if (chats.length <= _syncedCount) return;

    final newChats = chats.sublist(_syncedCount);
    _syncedCount = chats.length;

    setState(() {
      if (_isReadingPastMessages) {
        _pendingMessages.addAll(newChats);
      } else {
        _messages.addAll(newChats);
      }
    });

    if (!_isReadingPastMessages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _releasePendingMessages() {
    setState(() {
      _messages.addAll(_pendingMessages);
      _pendingMessages.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 상대방 메시지 수신 시뮬레이션
  void _receiveMessage(Chat message) {
    _messageController.clear();
    dataManager.addChat(widget.match.chattingID, message);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    if (_pendingMessages.isNotEmpty) _releasePendingMessages();

    final chat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sendUser: loginManager.currentUserOrGuest,
      chatText: _messageController.text,
      sendTime: DateTime.now(),
    );
    _messageController.clear();
    dataManager.addChat(widget.match.chattingID, chat);
  }

  void _updateRentalStatus() {
    RentalStatus nextStatus;

    switch (_currentStatus) {
      case RentalStatus.pending:
        nextStatus = RentalStatus.matchConfirmed;
        dataManager.confirmMatch(widget.match.matchID);
        break;
      case RentalStatus.matchConfirmed:
        nextStatus = RentalStatus.inProgress;
        dataManager.updateMatchStatus(widget.match.matchID, nextStatus);
        break;
      case RentalStatus.inProgress:
        nextStatus = RentalStatus.returned;
        dataManager.updateMatchStatus(widget.match.matchID, nextStatus);
        break;
      case RentalStatus.returned:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewScreen(
              rentalItem: widget.rentalItem,
              match: widget.match,
              reviewee: loginManager.currentUserOrGuest,
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
      case RentalStatus.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text(
              '취소된 거래입니다',
              style: TextStyle(color: context.onSurfaceColor),
            ),
            backgroundColor: RentalStatus.cancelled.color.withValues(
              alpha: 0.8,
            ),
          ),
        );
        return;
      case RentalStatus.otherUserMatched:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 500),
            content: Text(
              '다른 사용자와 매칭된 거래입니다',
              style: TextStyle(color: context.onSurfaceColor),
            ),
            backgroundColor: RentalStatus.otherUserMatched.color.withValues(
              alpha: 0.8,
            ),
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
        backgroundColor: context.primaryColor,
        foregroundColor: context.onPrimaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_otherUser.name),
            Text(
              widget.rentalItem.product.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '물건 상세정보',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ItemDetailScreen(item: widget.rentalItem),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: dataManager,
        builder: (context, child) {
          // 아이템이 다른 매치로 확정된 경우 버튼 비활성화
          final latestItem =
              dataManager.rentalItems[widget.rentalItem.id] ??
              widget.rentalItem;
          final isActiveParticipant =
              !latestItem.isMatched ||
              latestItem.matchedID == widget.match.matchID;

          return Column(
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
                    if (!isActiveParticipant) ...[
                      const Spacer(),
                      Text(
                        '다른 대여자와 매칭됨',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) => RefreshIndicator(
                        onRefresh: _refreshMessages,
                        child: _messages.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          '아직 메시지가 없습니다',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                shrinkWrap: true,
                                reverse: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message =
                                      _messages[_messages.length - 1 - index];
                                  return ChatWidgetFactory(
                                    message: message,
                                    currentUserId:
                                        loginManager.currentUserOrGuest.id,
                                  ).makeWidget(context);
                                },
                              ),
                      ),
                    ),
                    if (_pendingMessages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              _releasePendingMessages();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
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
                          onPressed: isActiveParticipant
                              ? _updateRentalStatus
                              : null,
                          icon: Icon(_getNextStatusIcon()),
                          label: Text(_currentStatus.nextButtonText),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isActiveParticipant
                                ? _getNextStatusColor()
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
                              // 테스트용: 엔터를 치면 상대방이 메시지를 보내는 것으로 시뮬레이션
                              // 실제 구현 시 삭제
                              onSubmitted: (_) => _receiveMessage(
                                Chat(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  sendUser: _otherUser,
                                  chatText: _messageController.text,
                                  sendTime: DateTime.now(),
                                ),
                              ),
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
          );
        },
      ),
    );
  }

  Color _getNextStatusColor() {
    switch (_currentStatus) {
      case RentalStatus.pending:
        return RentalStatus.matchConfirmed.color;
      case RentalStatus.matchConfirmed:
        return RentalStatus.inProgress.color;
      case RentalStatus.inProgress:
        return RentalStatus.returned.color;
      case RentalStatus.returned:
        return RentalStatus.reviewed.color;
      case RentalStatus.reviewed:
      case RentalStatus.cancelled:
      case RentalStatus.otherUserMatched:
        return Colors.grey;
    }
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
      case RentalStatus.cancelled:
        return Icons.cancel;
      case RentalStatus.otherUserMatched:
        return Icons.person_off;
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
      case RentalStatus.cancelled:
        return Icons.cancel;
      case RentalStatus.otherUserMatched:
        return Icons.person_off;
    }
  }
}
