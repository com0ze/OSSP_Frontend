import 'package:open_source_software/models/user.dart';

class Chat {
  final String id;
  final User sendUser;
  final String chatText;
  final DateTime sendTime;
  final bool isRead;

  Chat({
    required this.id,
    required this.sendUser,
    required this.chatText,
    required this.sendTime,
    this.isRead = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      sendUser: User.fromJson(json['sendUser']),
      chatText: json['chatText'],
      sendTime: DateTime.parse(json['sendTime']),
      isRead: json['isRead'] ?? false,
    );
  }

  // GET /api/v1/chats/{roomId}/messages 응답의 각 메시지 항목
  factory Chat.fromApi(Map<String, dynamic> json) {
    final senderId = json['senderId'].toString();
    return Chat(
      id: json['messageId']?.toString() ?? senderId,
      sendUser: User(id: senderId, name: '', email: ''),
      chatText: json['content'] as String,
      sendTime: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sendUser': sendUser.toJson(),
      'chatText': chatText,
      'sendTime': sendTime.toIso8601String(),
      'isRead': isRead,
    };
  }

  Chat copyWith({
    bool? isRead,
  }) {
    return Chat(
      id: id,
      sendUser: sendUser,
      chatText: chatText,
      sendTime: sendTime,
      isRead: isRead ?? this.isRead,
    );
  }
}
