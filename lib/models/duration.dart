class Duration {
  final DateTime startTime;
  final DateTime endTime;

  Duration({
    required this.startTime,
    required this.endTime,
  }) : assert(startTime.isBefore(endTime), 'startTime must be before endTime');

  factory Duration.fromJson(Map<String, dynamic> json) {
    return Duration(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  int get durationInDays {
    return endTime.difference(startTime).inDays;
  }

  int get durationInHours {
    return endTime.difference(startTime).inHours;
  }

  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool isExpired() {
    return DateTime.now().isAfter(endTime);
  }

  Duration copyWith({
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return Duration(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
