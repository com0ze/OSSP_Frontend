class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final double score;
  final List<String> dealHistory;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.score = 0,
    List<String>? dealHistory,
  }) : dealHistory = dealHistory ?? [];

  void addDealHistory(String dealId) {
    if (!dealHistory.contains(dealId)) {
      dealHistory.add(dealId);
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      score: json['score'] ?? 0,
      dealHistory: (json['dealHistory'] as List<dynamic>?)
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
      'dealHistory': dealHistory,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? profileImage,
    double? score,
    List<String>? dealHistory,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      score: score ?? this.score,
      dealHistory: dealHistory ?? List.from(this.dealHistory),
    );
  }
}
