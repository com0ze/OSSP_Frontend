import 'package:open_source_software/chat.dart';

class Chatting {
  final List<Chat> _chats;
  Chatting(this._chats);

  List<Chat> get chats => _chats;
  void addChat(Chat chat) {
    _chats.add(chat);
  }
}
