
class ProfileContentSession {
  int contentId;
  String contentKey;
  int? contentLength;
  String type;
  String title;
  DateTime startTime;
  int durationSeconds;

  ProfileContentSession(
      {required this.contentId,
      required this.contentKey,
      this.contentLength,
      required this.type,
      required this.title,
      required this.startTime,
      required this.durationSeconds});

  factory ProfileContentSession.fromMap(Map<String, Object?> map) =>
      ProfileContentSession(
          contentId: map['contentId'] as int,
          contentKey: map['contentKey'] as String,
          contentLength: map['contentLength'] as int?,
          startTime: DateTime.parse(map['startTime'] as String),
          durationSeconds: map['durationSeconds'] as int,
          title: map['title'] as String,
          type: map['type'] as String);
}
