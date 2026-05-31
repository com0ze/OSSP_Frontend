import '/models/product.dart';
import '/models/rental_status.dart';

export '/models/rental_status.dart';

class RentalItem {
  final String id;
  final Product product;
  final String buildingName;
  final int price;
  final String description; // 백에서는 memo
  final String requesterID;
  final String requesterName;
  final DateTime createdAt;
  final int duration; // 분 단위
  final List<String> matchIDs;
  final bool isMatched;
  final String? matchedID;
  final RentalStatus rentalStatus;

  RentalItem({
    required this.id,
    required this.product,
    required this.buildingName,
    required this.price,
    required this.description,
    required this.requesterID,
    this.requesterName = '',
    required this.createdAt,
    this.duration = 3600,
    this.matchIDs = const [],
    this.isMatched = false,
    this.matchedID,
    this.rentalStatus = RentalStatus.pending,
  });

  factory RentalItem.placeholder(String id) => RentalItem(
        id: id,
        product: Product(name: '', category: ''),
        buildingName: '',
        price: 0,
        description: '',
        requesterID: '',
        createdAt: DateTime.now(),
      );

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    final itemName = json['itemName'] as String?;
    return RentalItem(
      id: (json['requestId'] ?? json['id'] ?? '').toString(),
      product: itemName != null
          ? Product(name: itemName, category: '기타')
          : Product.fromJson(json['product'] as Map<String, dynamic>),
      buildingName: (json['buildingName'] ?? '').toString(),
      price: ((json['rewardAmt'] ?? json['price'] ?? 0) as num).toInt(),
      duration: ((json['duration'] as num?)?.toInt() ?? 3600),
      description: (json['memo'] ?? json['description'] ?? '').toString(),
      requesterID: (json['requesterId'] ?? json['requesterID'] ?? '')
          .toString(),
      requesterName: (json['requesterNickname'] ?? json['requesterName'] ?? '')
          .toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      matchIDs:
          (json['matchIDs'] as List<dynamic>?)?.cast<String>() ??
          (json['matchId'] != null ? [(json['matchId']).toString()] : []),
      isMatched:
          json['matchId'] != null || (json['isMatched'] as bool? ?? false),
      matchedID: (json['matchId'] != null ? (json['matchId']).toString() : ""),
      rentalStatus: _parseStatus(json['status'] ?? json['rentalStatus']),
    );
  }

  static RentalStatus _parseStatus(dynamic status) {
    if (status == null) return RentalStatus.pending;
    switch (status.toString().toUpperCase()) {
      case 'WAITING':
        return RentalStatus.pending;
      case 'MATCHED':
        return RentalStatus.matchConfirmed;
      case 'IN_USE':
        return RentalStatus.inProgress;
      case 'COMPLETED':
        return RentalStatus.returned;
      case 'CANCELED':
        return RentalStatus.cancelled;
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
      'buildingName': buildingName,
      'rewardAmt': price,
      'duration': duration,
      'memo': description,
      'requesterId': requesterID,
    };
  }

  RentalItem copyWith({
    int? duration,
    List<String>? matchIDs,
    bool? isMatched,
    String? matchedID,
    bool clearMatchedID = false,
    RentalStatus? rentalStatus,
  }) {
    return RentalItem(
      id: id,
      product: product,
      buildingName: buildingName,
      price: price,
      description: description,
      requesterID: requesterID,
      requesterName: requesterName,
      createdAt: createdAt,
      duration: duration ?? this.duration,
      matchIDs: matchIDs ?? this.matchIDs,
      isMatched: isMatched ?? this.isMatched,
      matchedID: clearMatchedID ? null : (matchedID ?? this.matchedID),
      rentalStatus: rentalStatus ?? this.rentalStatus,
    );
  }
}
