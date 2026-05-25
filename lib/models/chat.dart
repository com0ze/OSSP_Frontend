class Chat {
  final String senderId;
  final String content;
  final DateTime createdAt;

  Chat({
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      senderId: (json['senderId'] ?? json['sendUser']?['id'] ?? '').toString(),
      content: (json['content'] ?? json['chatText'] ?? '') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['sendTime'] != null
              ? DateTime.parse(json['sendTime'] as String)
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
