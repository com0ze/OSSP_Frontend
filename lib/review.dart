import 'package:open_source_software/user.dart';

class Review {
  final int _score;
  final String _reviewText;
  final User _wirter;

  Review(this._score, this._reviewText, this._wirter);

  int get score => _score;
  String get reviewText => _reviewText;
  User get wirter => _wirter;
}
