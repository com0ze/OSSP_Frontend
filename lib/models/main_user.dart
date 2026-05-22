import 'package:open_source_software/models/user.dart';

class MainUser extends User {
  final String personalInformation;

  MainUser({
    required super.id,
    required super.name,
    required super.email,
    super.profileImage,
    super.score = 0,
    List<String>? rentalHistory,
    required this.personalInformation,
  }) : super(rentalHistory: rentalHistory ?? []);

  factory MainUser.fromJson(Map<String, dynamic> json) {
    return MainUser(
      id: json['id'],
      name: json['name'],
      score: json['score'] ?? 0,
      personalInformation: json['personalInformation'] ?? '',
      rentalHistory: (json['rentalHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'personalInformation': personalInformation,
      'rentalHistory': rentalHistory,
      'email': email,
      'profileImage': profileImage,
    };
  }

  @override
  MainUser copyWith({
    String? id,
    String? name,
    double? score,
    String? personalInformation,
    List<String>? rentalHistory,
    String? email,
    String? profileImage,
  }) {
    return MainUser(
      id: this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      personalInformation: personalInformation ?? this.personalInformation,
      rentalHistory: rentalHistory ?? List.from(this.rentalHistory),
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
