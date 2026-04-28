import 'package:flutter/material.dart';
import '../models/chatting.dart';
import 'show_widget.dart';
import 'show_chat.dart';

class ShowChatting extends ShowWidget {
  final Chatting chatting;
  final String currentUserId;

  ShowChatting({
    required this.chatting,
    required this.currentUserId,
  });

  @override
  Widget makeWidget() {
    return ListView.builder(
      itemCount: chatting.chats.length,
      itemBuilder: (context, index) {
        final chat = chatting.chats[index];
        return ShowChat(
          chat: chat,
          currentUserId: currentUserId,
        ).makeWidget();
      },
    );
  }
}
