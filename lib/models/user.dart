class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final double score;
  final List<String> rentalHistory;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.score = 0,
    List<String>? rentalHistory,
  }) : rentalHistory = rentalHistory ?? [];

  void addrentalHistory(String dealId) {
    if (!rentalHistory.contains(dealId)) {
      rentalHistory.add(dealId);
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      score: json['score'] ?? 0,
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
