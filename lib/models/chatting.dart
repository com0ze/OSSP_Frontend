import 'package:open_source_software/models/chat.dart';

class Chatting {
  final String id;
  final List<Chat> _chats;

  Chatting({
    required this.id,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chats': _chats.map((e) => e.toJson()).toList(),
    };
  }

  Chatting copyWith({
    String? id,
    List<Chat>? chats,
  }) {
    return Chatting(
      id: id ?? this.id,
      chats: chats ?? List.from(_chats),
    );
  }
}
