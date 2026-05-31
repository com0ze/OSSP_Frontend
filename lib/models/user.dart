class User {
  final String id;
  final String name;
  final double score;
  final int rentalCount;

  User({
    required this.id,
    required this.name,
    this.score = 0,
    this.rentalCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      name: (json['nickname'] ?? json['name'] ?? '') as String,
      score:
          ((json['mannerScore'] ?? json['score']) as num?)?.toDouble() ?? 0.0,
      rentalCount: (json['rentalCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'rentalCount': rentalCount,
    };
  }

  User copyWith({
    String? name,
    double? score,
    int? rentalCount,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      score: score ?? this.score,
      rentalCount: rentalCount ?? this.rentalCount,
    );
  }
}
