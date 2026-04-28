import 'package:open_source_software/deal.dart';

class User {
  final String _name;
  int score;
  final List<Deal> _dealHistory;

  User(this._name, this.score, this._dealHistory);
  String get name => _name;
  List<Deal> get dealHistory => _dealHistory;

  void addDealHistory(Deal dealHistory) {
    _dealHistory.add(dealHistory);
  }
}
