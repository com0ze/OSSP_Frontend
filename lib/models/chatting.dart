import '/models/chat.dart';

class Chatting {
  final String id;
  final List<Chat> _chats;

  Chatting({required this.id, List<Chat>? chats}) : _chats = chats ?? [];

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

  // 서버 응답(roomId/messages) 또는 레거시 형식(id/chats) 모두 지원
  factory Chatting.fromJson(Map<String, dynamic> json) {
    final rawChats =
        json['messages'] as List<dynamic>? ?? json['chats'] as List<dynamic>?;
    return Chatting(
      id: (json['roomId'] ?? json['id'] ?? '').toString(),
      chats: rawChats
          ?.map((e) => Chat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'chats': _chats.map((e) => e.toJson()).toList()};
  }

  Chatting copyWith({String? id, List<Chat>? chats}) {
    return Chatting(id: id ?? this.id, chats: chats ?? List.from(_chats));
  }
}
