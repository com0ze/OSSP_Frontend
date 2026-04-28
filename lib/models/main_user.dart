class MainUser {
  final String id;
  final String name;
  final int mannerScore;
  final String personalInformation;
  final List<String> dealHistory;
  final String email;
  final String? profileImage;

  MainUser({
    required this.id,
    required this.name,
    required this.mannerScore,
    required this.personalInformation,
    List<String>? dealHistory,
    required this.email,
    this.profileImage,
  }) : dealHistory = dealHistory ?? [];

  void addDealHistory(String dealId) {
    if (!dealHistory.contains(dealId)) {
      dealHistory.add(dealId);
    }
  }

  factory MainUser.fromJson(Map<String, dynamic> json) {
    return MainUser(
      id: json['id'],
      name: json['name'],
      mannerScore: json['mannerScore'] ?? 0,
      personalInformation: json['personalInformation'] ?? '',
      dealHistory: (json['dealHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mannerScore': mannerScore,
      'personalInformation': personalInformation,
      'dealHistory': dealHistory,
      'email': email,
      'profileImage': profileImage,
    };
  }

  MainUser copyWith({
    String? name,
    int? mannerScore,
    String? personalInformation,
    List<String>? dealHistory,
    String? email,
    String? profileImage,
  }) {
    return MainUser(
      id: id,
      name: name ?? this.name,
      mannerScore: mannerScore ?? this.mannerScore,
      personalInformation: personalInformation ?? this.personalInformation,
      dealHistory: dealHistory ?? List.from(this.dealHistory),
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
