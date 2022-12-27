class ProfileGoal {
  int id;
  DateTime date;
  int goalSeconds;

  ProfileGoal(
      {this.id = 0,
      required this.date,
      required this.goalSeconds});

  factory ProfileGoal.fromMap(Map<String, Object?> map) => ProfileGoal(
      id: map['id'] as int,
      date: DateTime.parse(map['date'] as String),
      goalSeconds: map['goalSeconds'] as int);
}
