
class ProfileContentSession {
  int contentId;
  String contentKey;
  String type;
  String title;
  DateTime startTime;
  int durationSeconds;

  ProfileContentSession(
      {required this.contentId,
      required this.contentKey,
      required this.type,
      required this.title,
      required this.startTime,
      required this.durationSeconds});

  factory ProfileContentSession.fromMap(Map<String, Object?> map) =>
      ProfileContentSession(
          contentId: map['contentId'] as int,
          contentKey: map['contentKey'] as String,
          startTime: DateTime.parse(map['startTime'] as String),
          durationSeconds: map['durationSeconds'] as int,
          title: map['title'] as String,
          type: map['type'] as String);
}
