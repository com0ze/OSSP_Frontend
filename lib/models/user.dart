class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final double rating;
  final int totalRentals;
  final int totalLends;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.rating = 0.0,
    this.totalRentals = 0,
    this.totalLends = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRentals: json['totalRentals'] ?? 0,
      totalLends: json['totalLends'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'rating': rating,
      'totalRentals': totalRentals,
      'totalLends': totalLends,
    };
  }
}
