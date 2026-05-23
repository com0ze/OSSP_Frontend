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
