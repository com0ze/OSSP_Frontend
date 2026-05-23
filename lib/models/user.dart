class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final double score;
  final List<String> dealHistory;

  // 💡 백엔드 DB 스키마 업데이트 반영
  final String? fcmToken;
  final bool isOnDuty;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.score = 0,
    List<String>? dealHistory,
    this.fcmToken,
    this.isOnDuty = true,
  }) : dealHistory = dealHistory ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // 백엔드 Long타입 대응
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      dealHistory: (json['dealHistory'] as List<dynamic>?)?.map((e) => e as String).toList(),
      fcmToken: json['fcmToken'],
      isOnDuty: json['isOnDuty'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'score': score,
      'dealHistory': dealHistory,
      'fcmToken': fcmToken,
      'isOnDuty': isOnDuty,
    };
  }
}