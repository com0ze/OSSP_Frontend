class Review {
  final String id;
  final double score;
  final String reviewText;
  String writerId;
  String? revieweeId;
  String? matchId;
  String? reviewerNickname;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.score,
    required this.reviewText,
    required this.writerId,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['reviewId'] ?? json['id'] ?? '').toString(),
      score: ((json['score']) as num?)?.toDouble() ?? 0.0,
      reviewText: (json['comments'] ?? json['reviewText'] ?? '') as String,
      writerId: (json['reviewerId'] ?? json['writerId'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    )
      ..revieweeId = json['revieweeId']?.toString()
      ..matchId = (json['matchId'] ?? '').toString()
      ..reviewerNickname = json['reviewerNickname'] as String?;
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
      'writerId': writerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Review copyWith({String? id, double? score, String? reviewText}) {
    return Review(
      id: id ?? this.id,
      score: score ?? this.score,
      reviewText: reviewText ?? this.reviewText,
      writerId: writerId,
      createdAt: createdAt,
    );
  }
}
