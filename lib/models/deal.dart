import 'product.dart';
import 'user.dart';
import 'duration.dart';
import 'review.dart';
import 'chatting.dart';
import 'deal_status.dart';

class Deal {
  final String id;
  final Product product;
  final User seller;
  final User? buyer;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DealStatus status;
  final Review? review;
  final Chatting? chatting;
  final Duration duration;
  final int price;

  Deal({
    required this.id,
    required this.product,
    required this.seller,
    this.buyer,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    this.status = DealStatus.pending,
    this.review,
    this.chatting,
    required this.duration,
    required this.price,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'],
      product: Product.fromJson(json['product']),
      seller: User.fromJson(json['seller']),
      buyer: json['buyer'] != null ? User.fromJson(json['buyer']) : null,
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      status: DealStatus.values[json['status'] ?? 0],
      review: json['review'] != null ? Review.fromJson(json['review']) : null,
      chatting:
          json['chatting'] != null ? Chatting.fromJson(json['chatting']) : null,
      duration: Duration.fromJson(json['duration']),
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'seller': seller.toJson(),
      'buyer': buyer?.toJson(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.index,
      'review': review?.toJson(),
      'chatting': chatting?.toJson(),
      'duration': duration.toJson(),
      'price': price,
    };
  }

  Deal copyWith({
    Product? product,
    User? buyer,
    String? note,
    DateTime? updatedAt,
    DealStatus? status,
    Review? review,
    Chatting? chatting,
    Duration? duration,
    int? price,
  }) {
    return Deal(
      id: id,
      product: product ?? this.product,
      seller: seller,
      buyer: buyer ?? this.buyer,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      review: review ?? this.review,
      chatting: chatting ?? this.chatting,
      duration: duration ?? this.duration,
      price: price ?? this.price,
    );
  }
}
