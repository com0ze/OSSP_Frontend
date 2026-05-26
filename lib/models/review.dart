import 'package:open_source_software/models/user.dart';

class Review {
  final String id;
  final int score;
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
      id: json['id'],
      score: json['score'] ?? 0,
      reviewText: json['reviewText'],
      writer: User.fromJson(json['writer']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // GET /api/v1/users/me/reviews 응답의 각 리뷰 항목
  factory Review.fromApi(Map<String, dynamic> json) {
    final reviewerId = json['reviewerId']?.toString() ?? '';
    final reviewerName = json['reviewerNickname'] as String? ?? '';
    return Review(
      id: json['reviewId'].toString(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      reviewText: json['content'] as String? ?? '',
      writer: User(id: reviewerId, name: reviewerName, email: ''),
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

  Review copyWith({
    int? score,
    String? reviewText,
  }) {
    return Review(
      id: id,
      score: score ?? this.score,
      reviewText: reviewText ?? this.reviewText,
      writer: writer,
      createdAt: createdAt,
    );
  }
}
