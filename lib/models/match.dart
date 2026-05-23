class Match {
  final String matchID;
  final String rentalItemID;
  final String requesterID;
  final String lenderID;
  final String chattingID;
  final String? requesterReviewID;
  final String? lenderReviewID;

  const Match({
    required this.matchID,
    required this.rentalItemID,
    required this.requesterID,
    required this.lenderID,
    required this.chattingID,
    this.requesterReviewID,
    this.lenderReviewID,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchID: json['matchID'],
      rentalItemID: json['rentalItemID'],
      requesterID: json['requesterID'],
      lenderID: json['lenderID'],
      chattingID: json['chattingID'],
      requesterReviewID: json['requesterReviewID'],
      lenderReviewID: json['lenderReviewID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchID': matchID,
      'rentalItemID': rentalItemID,
      'requesterID': requesterID,
      'lenderID': lenderID,
      'chattingID': chattingID,
      'requesterReviewID': requesterReviewID,
      'lenderReviewID': lenderReviewID,
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
      requesterReviewID: requesterReviewID ?? this.requesterReviewID,
      lenderReviewID: lenderReviewID ?? this.lenderReviewID,
    );
  }
}
