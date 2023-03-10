import 'package:immersion_reader/data/profile/profile_content.dart';
import 'package:immersion_reader/data/profile/profile_content_session.dart';
import 'package:immersion_reader/data/profile/profile_content_stats.dart';
import 'package:immersion_reader/data/profile/profile_daily_stats.dart';
import 'package:immersion_reader/data/profile/profile_goal.dart';
import 'package:immersion_reader/data/profile/profile_session.dart';
import 'package:immersion_reader/storage/abstract_storage.dart';

class ProfileStorage extends AbstractStorage {
  @override
  String get databaseStorageName => databaseName;

  static const String databaseName = 'profile.db';
  static const int goalSeconds = 900;
  static const int sessionLimit = 500;

  static final ProfileStorage _singleton = ProfileStorage._internal();
  ProfileStorage._internal();
  factory ProfileStorage() => _singleton;

  Future<int> getContentIdElseCreate(ProfileContent content) async {
    var rows = await database!.rawQuery(
        'SELECT * FROM Content WHERE key = ? AND title = ? LIMIT 1;',
        [content.key.trim(), content.title.trim()]);
    if (rows.isNotEmpty) {
      ProfileContent oldContent = ProfileContent.fromMap(rows.first);
      await updateContentOnLaunch(oldContent, content);
      return oldContent.id;
    } else {
      return _createContent(content);
    }
  }

  Future<void> updateContentOnLaunch(
      ProfileContent oldContent, ProfileContent newContent) async {
    await database!.rawUpdate(
        'UPDATE Content SET contentLength = ?, lastOpened = ? WHERE id = ?', [
      newContent.contentLength,
      newContent.lastOpened.toIso8601String(),
      oldContent.id
    ]);
  }

  Future<void> updateContentVocabularyMined(
      int contentId, int difference) async {
    await database!.rawUpdate(
        'UPDATE Content SET vocabularyMined = vocabularyMined + ? WHERE id = ? ${difference < 0 ? 'AND vocabularyMined > 0' : ''}',
        [difference, contentId]);
  }

  Future<void> updateContentCurrentPosition(int contentId, int position) async {
    await database!.rawUpdate(
        'UPDATE Content SET currentPosition = ? WHERE id = ?',
        [position, contentId]);
  }

  Future<int> _createContent(ProfileContent content) async {
    return await database!.rawInsert(
        'INSERT INTO Content(key, title, type, lastOpened) VALUES(?, ?, ?, ?)',
        [
          content.key.trim(),
          content.title.trim(),
          content.type,
          content.lastOpened.toIso8601String()
        ]);
  }

  Future<ProfileGoal> getGoalOrCreate() async {
    DateTime now = DateTime.now();
    var rows = await database!.rawQuery(
        'SELECT * FROM Goals WHERE SUBSTR(date, 1, 10) = ? LIMIT 1;',
        [now.toIso8601String().substring(0, 10)]);
    if (rows.isNotEmpty) {
      ProfileGoal profileGoal = ProfileGoal.fromMap(rows.first);
      return profileGoal;
    } else {
      ProfileGoal goal = ProfileGoal(date: now, goalSeconds: goalSeconds);
      goal.id = await _createGoal(goal);
      return goal;
    }
  }

  Future<int> getGoalIdElseCreate() async {
    ProfileGoal profileGoal = await getGoalOrCreate();
    return profileGoal.id;
  }

  Future<int> _createGoal(ProfileGoal goal) async {
    return await database!.rawInsert(
        'INSERT INTO Goals(date, goalSeconds) VALUES(?, ?)',
        [goal.date.toIso8601String(), goal.goalSeconds]);
  }

  Future<void> createSession(ProfileSession session) async {
    await database!.rawInsert(
        'INSERT INTO Sessions(startTime, durationSeconds, contentId, goalId) VALUES(?, ?, ?, ?)',
        [
          session.startTime.toIso8601String(),
          session.durationSeconds,
          session.contentId,
          session.goalId
        ]);
  }

  Future<List<ProfileContentSession>> getContentSessions() async {
    var rows = await database!.rawQuery("""
      SELECT Content.id as 'contentId', Content.key as 'contentKey', Content.contentLength as 'contentLength', Content.title, Content.type, Sessions.startTime, Sessions.durationSeconds
      FROM Sessions
      INNER JOIN Content ON Content.id = Sessions.contentId
      ORDER BY Sessions.startTime DESC
      LIMIT ?;
      """, [sessionLimit]);
    if (rows.isNotEmpty) {
      List<ProfileContentSession> profileContentSessions =
          rows.map((row) => ProfileContentSession.fromMap(row)).toList();
      return profileContentSessions;
    } else {
      return [];
    }
  }

  Future<List<ProfileDailyStats>> getSessionStatsForMonth(
      {required int month, required int year}) async {
    String dateString = '${month < 10 ? '0' : ''}$month-$year';
    var rows = await database!.rawQuery("""
        SELECT startTime as date, goalId, SUM(durationSeconds) as totalSeconds
        FROM Sessions 
        WHERE strftime('%m-%Y', startTime) = ?
        GROUP BY goalId
        ORDER BY startTime DESC
        LIMIT ?;
        """, [dateString, sessionLimit]);
    if (rows.isNotEmpty) {
      List<ProfileDailyStats> profileDailyStats =
          rows.map((row) => ProfileDailyStats.fromMap(row)).toList();
      return profileDailyStats;
    } else {
      return [];
    }
  }

  Future<List<ProfileContentStats>> getProfileContentStats() async {
    var rows = await database!.rawQuery("""
        SELECT Content.id, Content.key, Content.title, 
        Content.contentLength, Content.currentPosition, Content.vocabularyMined,
        Content.lastOpened, Content.type, SUM(Sessions.durationSeconds) as totalSeconds
        FROM Sessions
        INNER JOIN Content ON Content.id = Sessions.contentId
        GROUP BY contentId
        ORDER BY Sessions.startTime DESC
        LIMIT ?;
        """, [sessionLimit]);
    if (rows.isNotEmpty) {
      List<ProfileContentStats> profileContentStats =
          rows.map((row) => ProfileContentStats.fromMap(row)).toList();
      return profileContentStats;
    } else {
      return [];
    }
  }

  // Future<List<ProfileSession>> getSessonsByGoalId(int goalId) async {
  //   var rows = await database!
  //       .rawQuery('SELECT * FROM Sessions WHERE goalId = ?', [goalId]);
  //   if (rows.isNotEmpty) {
  //     List<ProfileSession> profileSessions =
  //         rows.map((row) => ProfileSession.fromMap(row)).toList();
  //     return profileSessions;
  //   } else {
  //     return [];
  //   }
  // }

  Future<void> setGoalSeconds(int goalId, int goalSeconds) async {
    await database!.rawUpdate(
        'UPDATE Goals SET goalSeconds = ? WHERE id = ?', [goalSeconds, goalId]);
  }
}
