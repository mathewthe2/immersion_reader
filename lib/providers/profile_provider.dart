import 'dart:async';

import 'package:immersion_reader/data/profile/profile_content.dart';
import 'package:immersion_reader/data/profile/profile_content_session.dart';
import 'package:immersion_reader/data/profile/profile_goal.dart';
import 'package:immersion_reader/data/profile/profile_session.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';
import 'package:immersion_reader/storage/profile_storage.dart';

class ProfileProvider {
  ProfileStorage? profileStorage;
  ProfileSession? currentSession; // reading session
  int _hearbeatCount = 0;
  late Timer _timer;
  static const int heartBeatThreshold = 5; // minimum seconds of reading for a session

  ProfileProvider._create() {
    // print("_create() (private constructor)");
  }

  static Future<ProfileProvider> create() async {
    ProfileProvider provider = ProfileProvider._create();
    provider.profileStorage = await ProfileStorage.create();
    return provider;
  }

  void dispose() {
    _stopCounting();
  }

  Future<ProfileDailyProgress?> getDailyReadingProgress() async {
    if (profileStorage == null) {
      return null;
    }
    ProfileGoal profileGoal = await profileStorage!.getGoalOrCreate();
    List<ProfileContentSession> sessions =
        await profileStorage!.getContentSessions();
    return ProfileDailyProgress(
        goalId: profileGoal.id,
        goalSeconds: profileGoal.goalSeconds,
        contentSessions: sessions);
  }

  Future<void> startSession(ProfileContent content) async {
    if (profileStorage == null) {
      return;
    }
    int contentId = await profileStorage!.getContentIdElseCreate(content);
    int goalId = await profileStorage!.getGoalIdElseCreate();
    if (currentSession != null) {
      await restartSession();
    } else {
      _startCounting();
    }
    currentSession = createEmptySession(contentId: contentId, goalId: goalId);
  }

  Future<void> restartSession() async {
    if (currentSession != null && !currentSession!.isActive()) {
      currentSession!.durationSeconds = 0;
      currentSession!.activate();
      _stopCounting();
      _startCounting();
    }
  }

  // session ended but can be restarted. accessible by switching tabs
  Future<void> endSession() async {
    if (currentSession != null && currentSession!.isActive()) {
      currentSession!.durationSeconds = _hearbeatCount;
      _stopCounting();
      currentSession!.retire();
      if (currentSession!.durationSeconds >= heartBeatThreshold) {
        await profileStorage!
            .createSession(currentSession!); // saves session to database
      }
    }
  }

  // session is ended and cannot be restarted. requires new session
  Future<void> destroySession() async {
    await endSession();
    currentSession?.kill(); // garbage collect here if necessary to save memory
  }

  void _startCounting() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _hearbeatCount += 1;
    });
  }

  void _stopCounting() {
    _timer.cancel();
    _hearbeatCount = 0;
  }

  static ProfileSession createEmptySession(
      {required int contentId, required int goalId}) {
    return ProfileSession(
        startTime: DateTime.now(),
        durationSeconds: 0,
        contentId: contentId,
        goalId: goalId);
  }

  void updateGoalMinutes(int goalId, int goalMinutes) {
    profileStorage?.setGoalSeconds(goalId, goalMinutes * 60);
  }
}
