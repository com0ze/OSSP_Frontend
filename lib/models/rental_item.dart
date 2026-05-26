import 'package:open_source_software/models/product.dart';
import 'package:open_source_software/models/rental_status.dart';

export 'package:open_source_software/models/rental_status.dart';

class RentalItem {
  final String id;
  final String title;
  final Product product;
  final String placeID;
  final int price;
  final int duration; // 대여 시간 (분)
  final String description;
  final String preferences;
  final String requesterID;
  final String? providerID; // 매칭된 대여자 ID
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
    required this.placeID,
    required this.price,
    this.duration = 60,
    required this.description,
    required this.preferences,
    required this.requesterID,
    this.providerID,
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
      placeID: json['placeID'],
      price: json['price'],
      duration: json['duration'] ?? 60,
      description: json['description'],
      preferences: json['preferences'],
      requesterID: json['requesterID'],
      providerID: json['providerID'],
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

  factory RentalItem.fromApi(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'WAITING';
    final RentalStatus status = switch (statusStr) {
      'MATCHED' => RentalStatus.matchConfirmed,
      'IN_USE' => RentalStatus.inProgress,
      'COMPLETED' => RentalStatus.returned,
      'CANCELED' => RentalStatus.cancelled,
      _ => RentalStatus.pending,
    };
    final isMatched =
        statusStr != 'WAITING' && statusStr != 'CANCELED';
    final itemName = json['itemName'] as String? ?? '';
    return RentalItem(
      id: json['requestId'].toString(),
      title: itemName,
      product: Product(name: itemName, category: ''),
      placeID: json['buildingName'] as String? ?? '',
      price: (json['rewardAmt'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      description: json['memo'] as String? ?? '',
      preferences: '',
      requesterID: json['requesterId']?.toString() ?? '',
      providerID: json['providerId']?.toString(),
      matchedID: json['matchId']?.toString(), // DataManager Match 파생에 필요
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isMatched: isMatched,
      rentalStatus: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'product': product.toJson(),
      'placeID': placeID,
      'price': price,
      'duration': duration,
      'description': description,
      'preferences': preferences,
      'requesterID': requesterID,
      'providerID': providerID,
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
    String? providerID,
    RentalStatus? rentalStatus,
  }) {
    return RentalItem(
      id: id,
      title: title,
      product: product,
      placeID: placeID,
      price: price,
      duration: duration,
      description: description,
      preferences: preferences,
      requesterID: requesterID,
      providerID: providerID ?? this.providerID,
      createdAt: createdAt,
      imageUrl: imageUrl,
      matchIDs: matchIDs ?? this.matchIDs,
      isMatched: isMatched ?? this.isMatched,
      matchedID: clearMatchedID ? null : (matchedID ?? this.matchedID),
      rentalStatus: rentalStatus ?? this.rentalStatus,
    );
  }
}
