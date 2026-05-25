import '/models/user.dart';

class Review {
  final String id;
  final double score;
  final String reviewText;
  final User writer;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.score,
    required this.reviewText,
    required this.writer,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['reviewId'] ?? json['id'] ?? '').toString(),
      score: ((json['score']) as num?)?.toDouble() ?? 0.0,
      reviewText: (json['comments'] ?? json['reviewText'] ?? '') as String,
      writer: json['writer'] != null
          ? User.fromJson(json['writer'] as Map<String, dynamic>)
          : User(
              id: (json['reviewerId'] ?? '').toString(),
              name: (json['writerNickname'] ?? '알 수 없음') as String,
            ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'reviewText': reviewText,
      'writer': writer.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Review copyWith({String? id, double? score, String? reviewText}) {
    return Review(
      id: id ?? this.id,
      score: score ?? this.score,
      reviewText: reviewText ?? this.reviewText,
      writer: writer,
      createdAt: createdAt,
    );
  }
}
