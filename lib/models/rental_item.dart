import '/models/product.dart';
import '/models/rental_status.dart';

export '/models/rental_status.dart';

class RentalItem {
  final String id;
  final String title;
  final Product product;
  final String placeID;
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
    required this.placeID,
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

  // 서버 응답(requestId/itemName/buildingName/rewardAmt/memo/status) 또는
  // 레거시 형식(id/title/product/placeID/price/description) 모두 지원
  factory RentalItem.fromJson(Map<String, dynamic> json) {
    final itemName = json['itemName'] as String?;
    return RentalItem(
      id: (json['requestId'] ?? json['id'] ?? '').toString(),
      title: itemName ?? (json['title'] as String? ?? ''),
      product: itemName != null
          ? Product(name: itemName, category: '기타')
          : Product.fromJson(json['product'] as Map<String, dynamic>),
      placeID: (json['buildingName'] ?? json['placeID'] ?? '').toString(),
      price: ((json['rewardAmt'] ?? json['price'] ?? 0) as num).toInt(),
      description: (json['memo'] ?? json['description'] ?? '').toString(),
      preferences: (json['preferences'] ?? '').toString(),
      requesterID: (json['requesterId'] ?? json['requesterID'] ?? '')
          .toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
      matchIDs:
          (json['matchIDs'] as List<dynamic>?)?.cast<String>() ??
          (json['matchId'] != null ? [(json['matchId']).toString()] : []),
      isMatched:
          json['matchId'] != null || (json['isMatched'] as bool? ?? false),
      matchedID: (json['matchId'] ?? json['matchedID']) as String?,
      rentalStatus: _parseStatus(json['status'] ?? json['rentalStatus']),
    );
  }

  static RentalStatus _parseStatus(dynamic status) {
    if (status == null) return RentalStatus.pending;
    switch (status.toString().toUpperCase()) {
      case 'PENDING':
        return RentalStatus.pending;
      case 'ACCEPTED':
        return RentalStatus.matchConfirmed;
      case 'HANDOVER':
        return RentalStatus.inProgress;
      case 'COMPLETE':
        return RentalStatus.returned;
      case 'CANCELLED':
        return RentalStatus.cancelled;
      case 'REVIEWED':
        return RentalStatus.reviewed;
      default:
        try {
          return RentalStatus.values.byName(status.toString());
        } catch (_) {
          return RentalStatus.pending;
        }
    }
  }

  // POST /api/v1/requests 요청 바디 형식
  Map<String, dynamic> toJson() {
    return {
      'itemName': product.name,
      'buildingName': placeID,
      'rewardAmt': price,
      'duration': 60,
      'memo': description,
      'requesterId': requesterID,
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
      placeID: placeID,
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
