import 'package:immersion_reader/extensions/datetime_extension.dart';

class ProfileDailyStats {
  DateTime date;
  int goalId;
  int totalSeconds;

  ProfileDailyStats(
      {required this.date, required this.goalId, required this.totalSeconds});

  factory ProfileDailyStats.fromMap(Map<String, Object?> map) =>
      ProfileDailyStats(
          date: DateTime.parse(map['date'] as String).dateOnly(),
          goalId: map['goalId'] as int,
          totalSeconds: map['totalSeconds'] as int);
}
