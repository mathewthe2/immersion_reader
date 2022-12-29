import 'package:flutter/foundation.dart';

enum ProfileSessionState { active, retired, dead }

class ProfileSession {
  int id;
  DateTime startTime;
  int durationSeconds;
  int contentId; // id of content user engaged in
  int goalId; // id of goal

  ProfileSessionState sessionState = ProfileSessionState.active;

  ProfileSession(
      {this.id = 0,
      required this.startTime,
      required this.durationSeconds,
      required this.contentId,
      required this.goalId});

  factory ProfileSession.fromMap(Map<String, Object?> map) => ProfileSession(
      id: map['id'] as int,
      startTime: DateTime.parse(map['startTime'] as String),
      durationSeconds: map['durationSeconds'] as int,
      contentId: map['contentId'] as int,
      goalId: map['goalId'] as int);

  bool isActive() {
    return sessionState == ProfileSessionState.active;
  }

  void retire() {
    sessionState = ProfileSessionState.retired;
  }

  void activate() {
    if (sessionState == ProfileSessionState.dead) {
      debugPrint("Warning: tried to bring dead profile session from the dead.");
    } else {
      sessionState = ProfileSessionState.active;
    }
  }

  void kill() {
    sessionState = ProfileSessionState.dead;
  }
}
