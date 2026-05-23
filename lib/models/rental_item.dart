import 'package:open_source_software/models/product.dart';
import 'package:open_source_software/models/rental_status.dart';

export 'package:open_source_software/models/rental_status.dart';

class RentalItem {
  final String id;
  final String title;
  final Product product;
  final String location;
  final int price;
  final String description;
  final String preferences;
  final String requesterID;
  final DateTime createdAt;
  final String? imageUrl;
  final List<String> matchIDs;
  final bool isMatched;
  final String? matchedID;
  final RentalStatus rentalStatus;

  RentalItem({
    required this.id,
    required this.title,
    required this.product,
    required this.location,
    required this.price,
    required this.description,
    required this.preferences,
    required this.requesterID,
    required this.createdAt,
    this.imageUrl,
    this.matchIDs = const [],
    this.isMatched = false,
    this.matchedID,
    this.rentalStatus = RentalStatus.pending,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      id: json['id'],
      title: json['title'],
      product: Product.fromJson(json['product']),
      location: json['location'],
      price: json['price'],
      description: json['description'],
      preferences: json['preferences'],
      requesterID: json['requesterID'],
      createdAt: DateTime.parse(json['createdAt']),
      imageUrl: json['imageUrl'],
      matchIDs: (json['matchIDs'] as List<dynamic>?)?.cast<String>() ?? [],
      isMatched: json['isMatched'] ?? false,
      matchedID: json['matchedID'],
      rentalStatus: json['rentalStatus'] != null
          ? RentalStatus.values.byName(json['rentalStatus'])
          : RentalStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'product': product.toJson(),
      'location': location,
      'price': price,
      'description': description,
      'preferences': preferences,
      'requesterID': requesterID,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'matchIDs': matchIDs,
      'isMatched': isMatched,
      'matchedID': matchedID,
      'rentalStatus': rentalStatus.name,
    };
  }

  RentalItem copyWith({
    List<String>? matchIDs,
    bool? isMatched,
    String? matchedID,
    bool clearMatchedID = false,
    RentalStatus? rentalStatus,
  }) {
    return RentalItem(
      id: id,
      title: title,
      product: product,
      location: location,
      price: price,
      description: description,
      preferences: preferences,
      requesterID: requesterID,
      createdAt: createdAt,
      imageUrl: imageUrl,
      matchIDs: matchIDs ?? this.matchIDs,
      isMatched: isMatched ?? this.isMatched,
      matchedID: clearMatchedID ? null : (matchedID ?? this.matchedID),
      rentalStatus: rentalStatus ?? this.rentalStatus,
    );
  }
}
