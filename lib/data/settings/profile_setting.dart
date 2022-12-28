class ProfileSetting {
  int readingGoalSeconds;

  // keys for Database
  static const String readingGoalSecondsKey = 'reading_goal_seconds';

  ProfileSetting({required this.readingGoalSeconds});

  factory ProfileSetting.fromMap(Map<String, Object?> map) => ProfileSetting(
        readingGoalSeconds: int.parse(map[readingGoalSecondsKey] as String)
      );

  // static String urlFiltersToString(List<String> urlFilters) {
  //   return urlFilters.join("\n");
  // }
}
