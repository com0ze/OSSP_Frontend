import 'package:open_source_software/models/rental_status.dart';

class Match {
  final String matchID;
  final String rentalItemID;
  final String requesterID;
  final String lenderID;
  final String chattingID;
  final RentalStatus rentalStatus;
  final String? requesterReviewID;
  final String? lenderReviewID;

  const Match({
    required this.matchID,
    required this.rentalItemID,
    required this.requesterID,
    required this.lenderID,
    required this.chattingID,
    this.rentalStatus = RentalStatus.pending,
    this.requesterReviewID,
    this.lenderReviewID,
  });

  Match copyWith({
    String? matchID,
    String? rentalItemID,
    String? requesterID,
    String? lenderID,
    String? chattingID,
    RentalStatus? rentalStatus,
    String? requesterReviewID,
    String? lenderReviewID,
  }) {
    return Match(
      matchID: matchID ?? this.matchID,
      rentalItemID: rentalItemID ?? this.rentalItemID,
      requesterID: requesterID ?? this.requesterID,
      lenderID: lenderID ?? this.lenderID,
      chattingID: chattingID ?? this.chattingID,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      requesterReviewID: requesterReviewID ?? this.requesterReviewID,
      lenderReviewID: lenderReviewID ?? this.lenderReviewID,
    );
  }
}
