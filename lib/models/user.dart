class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final double score;
  final List<String> rentalHistory;

  // 💡 백엔드 DB 스키마 업데이트 반영
  final String? fcmToken;
  final bool isOnDuty;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.score = 0,
    this.fcmToken,
    this.isOnDuty = true,
    List<String>? rentalHistory,
  }) : rentalHistory = List<String>.from(rentalHistory ?? []);

  void addRentalHistory(String dealId) {
    if (!rentalHistory.contains(dealId)) {
      rentalHistory.add(dealId);
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // 백엔드 Long타입 대응
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      fcmToken: json['fcmToken'],
      isOnDuty: json['isOnDuty'] ?? true,
      rentalHistory: (json['rentalHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'score': score,
      'fcmToken': fcmToken,
      'isOnDuty': isOnDuty,
      'rentalHistory': rentalHistory,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? profileImage,
    double? score,
    List<String>? rentalHistory,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      score: score ?? this.score,
      rentalHistory: rentalHistory ?? List.from(this.rentalHistory),
    );
  }
}
