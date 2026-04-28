import 'user.dart';

enum RentalStatus {
  pending,
  matchConfirmed,
  inProgress,
  returned,
  reviewed,
}

class RentalItem {
  final String id;
  final String title;
  final String itemName;
  final String location;
  final int price;
  final String description;
  final String preferences;
  final User requester;
  final DateTime createdAt;
  final RentalStatus status;
  final User? lender;
  final String? imageUrl;

  RentalItem({
    required this.id,
    required this.title,
    required this.itemName,
    required this.location,
    required this.price,
    required this.description,
    required this.preferences,
    required this.requester,
    required this.createdAt,
    this.status = RentalStatus.pending,
    this.lender,
    this.imageUrl,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      id: json['id'],
      title: json['title'],
      itemName: json['itemName'],
      location: json['location'],
      price: json['price'],
      description: json['description'],
      preferences: json['preferences'],
      requester: User.fromJson(json['requester']),
      createdAt: DateTime.parse(json['createdAt']),
      status: RentalStatus.values[json['status'] ?? 0],
      lender: json['lender'] != null ? User.fromJson(json['lender']) : null,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'itemName': itemName,
      'location': location,
      'price': price,
      'description': description,
      'preferences': preferences,
      'requester': requester.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
      'lender': lender?.toJson(),
      'imageUrl': imageUrl,
    };
  }

  RentalItem copyWith({
    RentalStatus? status,
    User? lender,
  }) {
    return RentalItem(
      id: id,
      title: title,
      itemName: itemName,
      location: location,
      price: price,
      description: description,
      preferences: preferences,
      requester: requester,
      createdAt: createdAt,
      status: status ?? this.status,
      lender: lender ?? this.lender,
      imageUrl: imageUrl,
    );
  }
}
