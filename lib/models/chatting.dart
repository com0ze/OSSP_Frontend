import '/models/chat.dart';

class Chatting {
  final String id; // roomId
  final String matchId;
  final String requestId;
  final String opponentId;
  final String opponentName;
  final String? lastMessage; // 목록 API에서 내려주는 마지막 메시지 미리보기
  final DateTime? updatedAt;
  final List<Chat> _chats;

  Chatting({
    required this.id,
    this.matchId = '',
    this.requestId = '',
    this.opponentId = '',
    this.opponentName = '',
    this.lastMessage,
    this.updatedAt,
    List<Chat>? chats,
  }) : _chats = (chats ?? [])..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  List<Chat> get chats => List.unmodifiable(_chats);

  void addChat(Chat chat) {
    _chats.add(chat);
    _chats.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void addChats(List<Chat> newChats) {
    _chats.addAll(newChats);
    _chats.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void replaceChats(List<Chat> newChats) {
    _chats
      ..clear()
      ..addAll(newChats)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // 실제 메시지가 로드된 경우 마지막 Chat, 없으면 null
  Chat? getLastChat() => _chats.isEmpty ? null : _chats.last;

  // 실제 메시지 > 목록 API 미리보기 순으로 반환
  String? getLastMessageText() {
    if (_chats.isNotEmpty) return _chats.last.content;
    return lastMessage;
  }

  DateTime? getLastMessageTime() {
    if (_chats.isNotEmpty) return _chats.last.createdAt;
    return updatedAt;
  }

  factory Chatting.fromJson(Map<String, dynamic> json) {
    final rawChats = json['messages'] as List<dynamic>?;
    return Chatting(
      id: (json['roomId'] ?? json['id'] ?? '').toString(),
      matchId: (json['matchId'] ?? '').toString(),
      requestId: (json['requestId'] ?? '').toString(),
      opponentId: (json['opponentId'] ?? '').toString(),
      opponentName: (json['opponentName'] ?? '알 수 없음') as String,
      lastMessage: json['lastMessage'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['createdAt'] as String)
          : null,
      chats: rawChats
          ?.map((e) => Chat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'chats': _chats.map((e) => e.toJson()).toList()};
  }

  Chatting copyWith({
    String? id,
    List<Chat>? chats,
    String? matchId,
    String? requestId,
    String? opponentId,
    String? opponentName,
    String? lastMessage,
    DateTime? updatedAt,
  }) {
    return Chatting(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      requestId: requestId ?? this.requestId,
      opponentId: opponentId ?? this.opponentId,
      opponentName: opponentName ?? this.opponentName,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      chats: chats ?? List.from(_chats),
    );
  }
}
