import 'dart:math';
import 'package:immersion_reader/data/profile/profile_content_session.dart';
import 'package:immersion_reader/extensions/datetime_extension.dart';
import 'package:immersion_reader/utils/reader/local_asset_server_manager.dart';

class ProfileDailyProgress {
  int goalId;
  int goalSeconds;
  List<ProfileContentSession> contentSessions;

  ProfileDailyProgress(
      {required this.goalId,
      required this.goalSeconds,
      required this.contentSessions});

  List<ProfileContentSession> _getSessionsToday() {
    return contentSessions
        .where((session) => session.startTime.isToday())
        .toList();
  }

  // Map<DateTime, int> getSessionPerDayMap() {
  //   const sessionsMap = Map<DateTime, int>;
  //   contentSessions.forEach((contentSession) {
  //     sessionsMap[contentSession.startTime] = 
  //   });
  // }

  String getDayOfWeek() {
    return DateTime.now().dayOfWeek();
  }

  int getGoalMinutes() {
    return goalSeconds ~/ 60;
  }

  int _getTotalSecondsReadToday() {
    return _getSessionsToday().fold(
        0, (previousValue, session) => session.durationSeconds + previousValue);
  }

  double getPercentageReadToday() {
    return min(100, _getTotalSecondsReadToday() / goalSeconds * 100);
  }

  int _getMinutesToGo() {
    int maxGoalMinutes = goalSeconds ~/ 60;
    return min(
        maxGoalMinutes, 1 + (goalSeconds - _getTotalSecondsReadToday()) ~/ 60);
  }

  String getReadingTimeToGo() {
    int minutesToGo = _getMinutesToGo();
    return '$minutesToGo ${minutesToGo > 1 ? 'minutes' : 'minute'} to go';
  }

  String getTimeReadToday() {
    int totalSeconds = _getTotalSecondsReadToday();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    String secondString = seconds < 10 ? '0$seconds' : '$seconds';
    return '$minutes:$secondString';
  }

  String getRecentBookTitle() {
    if (contentSessions.isEmpty) {
      return '';
    }
    return contentSessions.first.title;
  }

  String getMediaIdentifier() {
    return 'http://localhost:${LocalAssetsServerManager.port}/b.html?id=${_getRecentBookKey()}';
  }

  String _getRecentBookKey() {
    if (contentSessions.isEmpty) {
      return '';
    }
    return contentSessions.first.contentKey;
  }
}
