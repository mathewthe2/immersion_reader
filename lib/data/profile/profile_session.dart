import 'package:flutter/foundation.dart';

enum ProfileSessionState { active, retired, dead }

class ProfileSession {
  int id;
  DateTime startTime;
  int durationSeconds;
  int contentId; // id of content user engaged in
  int goalId; // id of goal

  ProfileSessionState _sessionState = ProfileSessionState.active;

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
    return _sessionState == ProfileSessionState.active;
  }

  void retire() {
    _sessionState = ProfileSessionState.retired;
  }

  void activate() {
    if (_sessionState == ProfileSessionState.dead) {
      debugPrint("Warning: tried to bring dead profile session from the dead.");
    } else {
      _sessionState = ProfileSessionState.active;
    }
  }

  void kill() {
    _sessionState = ProfileSessionState.dead;
  }
}
