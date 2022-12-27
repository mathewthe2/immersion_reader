import 'dart:math';
import 'package:immersion_reader/data/profile/profile_content_session.dart';
import 'package:immersion_reader/extensions/datetime_extension.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';

class ProfileDailyProgress {
  int goalSeconds;
  List<ProfileContentSession> contentSessions;

  ProfileDailyProgress(
      {required this.goalSeconds, required this.contentSessions});

  List<ProfileContentSession> _getSessionsToday() {
    return contentSessions
        .where((session) => session.startTime.isToday())
        .toList();
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
    return 'http://localhost:${LocalAssetsServerProvider.port}/b.html?id=${_getRecentBookKey()}';
  }

  String _getRecentBookKey() {
    if (contentSessions.isEmpty) {
      return '';
    }
    return contentSessions.first.contentKey;
  }
}
