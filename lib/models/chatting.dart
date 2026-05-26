import 'package:open_source_software/models/chat.dart';

class Chatting {
  final String id;
  final String? matchId;
  final String? opponentId;
  final String? opponentName;
  final List<Chat> _chats;

  Chatting({
    required this.id,
    this.matchId,
    this.opponentId,
    this.opponentName,
    List<Chat>? chats,
  }) : _chats = chats ?? [];

  List<Chat> get chats => List.unmodifiable(_chats);

  void addChat(Chat chat) {
    _chats.add(chat);
  }

  void addChats(List<Chat> newChats) {
    _chats.addAll(newChats);
  }

  Chat? getLastChat() {
    if (_chats.isEmpty) return null;
    return _chats.last;
  }

  int get unreadCount {
    return _chats.where((chat) => !chat.isRead).length;
  }

  factory Chatting.fromJson(Map<String, dynamic> json) {
    return Chatting(
      id: json['id'],
      chats: (json['chats'] as List<dynamic>?)
          ?.map((e) => Chat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // GET /api/v1/chats 응답의 각 채팅방 항목
  factory Chatting.fromApi(Map<String, dynamic> json) {
    return Chatting(
      id: json['roomId'].toString(),
      matchId: json['matchId']?.toString(),
      opponentId: json['opponentId']?.toString(),
      opponentName: json['opponentName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chats': _chats.map((e) => e.toJson()).toList(),
    };
  }

  Chatting copyWith({
    String? id,
    String? matchId,
    String? opponentId,
    String? opponentName,
    List<Chat>? chats,
  }) {
    return Chatting(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      opponentId: opponentId ?? this.opponentId,
      opponentName: opponentName ?? this.opponentName,
      chats: chats ?? List.from(_chats),
    );
  }
}
