class Duration {
  final DateTime _startTime;
  final DateTime _endTime;

  Duration(this._startTime, this._endTime);

  DateTime get startTime => _startTime;
  DateTime get endTime => _endTime;
}
