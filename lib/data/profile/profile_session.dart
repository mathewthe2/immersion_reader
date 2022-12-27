class ProfileSession {
  int id;
  DateTime startTime;
  int durationSeconds;
  int contentId; // id of content user engaged in
  int goalId; // id of goal

  bool active = true;

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
}
