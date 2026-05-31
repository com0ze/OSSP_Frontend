class Match {
  final String matchID;
  final String rentalItemID;
  final String requesterID;
  final String lenderID;
  final String? chattingID;
  // final String? requesterReviewID;
  // final String? lenderReviewID;

  const Match({
    required this.matchID,
    required this.rentalItemID,
    required this.requesterID,
    required this.lenderID,
    this.chattingID,
    // this.requesterReviewID,
    // this.lenderReviewID,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchID: (json['matchId'] ?? json['matchID'] ?? '').toString(),
      rentalItemID: (json['requestId'] ?? json['rentalItemID'] ?? '')
          .toString(),
      requesterID: (json['requesterId'] ?? json['requesterID'] ?? '')
          .toString(),
      lenderID: (json['providerId'] ?? json['lenderID'] ?? '').toString(),
      chattingID: (json['roomId'] ?? json['chattingID'] ?? '').toString(),
      // requesterReviewID: json['requesterReviewID'] as String?,
      // lenderReviewID: json['lenderReviewID'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchID': matchID,
      'rentalItemID': rentalItemID,
      'requesterID': requesterID,
      'lenderID': lenderID,
      'chattingID': chattingID,
      // 'requesterReviewID': requesterReviewID,
      // 'lenderReviewID': lenderReviewID,
    };
  }

  Match copyWith({
    String? matchID,
    String? rentalItemID,
    String? requesterID,
    String? lenderID,
    String? chattingID,
    String? requesterReviewID,
    String? lenderReviewID,
  }) {
    return Match(
      matchID: matchID ?? this.matchID,
      rentalItemID: rentalItemID ?? this.rentalItemID,
      requesterID: requesterID ?? this.requesterID,
      lenderID: lenderID ?? this.lenderID,
      chattingID: chattingID ?? this.chattingID,
      // requesterReviewID: requesterReviewID ?? this.requesterReviewID,
      // lenderReviewID: lenderReviewID ?? this.lenderReviewID,
    );
  }
}
