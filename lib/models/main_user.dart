import '/models/user.dart';

class MainUser extends User {
  final String email;
  final bool isOnDuty;

  MainUser({
    required super.id,
    required super.name,
    required this.email,
    super.score = 0,
    super.rentalCount = 0,
    this.isOnDuty = false,
  });

  factory MainUser.fromJson(Map<String, dynamic> json) {
    return MainUser(
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      name: (json['nickname'] ?? json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      score:
          ((json['mannerScore'] ?? json['score']) as num?)?.toDouble() ?? 0.0,
      isOnDuty: (json['isOnDuty'] as bool?) ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'score': score,
      'isOnDuty': isOnDuty,
    };
  }

  @override
  MainUser copyWith({
    String? id,
    String? name,
    String? email,
    double? score,
    int? rentalCount,
    bool? isOnDuty,
  }) {
    return MainUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      score: score ?? this.score,
      rentalCount: rentalCount ?? this.rentalCount,
      isOnDuty: isOnDuty ?? this.isOnDuty,
    );
  }
}
