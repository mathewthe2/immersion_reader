class ProfileSetting {
  int readingGoalSeconds;

  // keys for Database
  static const String enableAdBlockKey = 'reading_goal_seconds';

  ProfileSetting({required this.readingGoalSeconds});

  factory ProfileSetting.fromMap(Map<String, Object?> map) => ProfileSetting(
        readingGoalSeconds: map[enableAdBlockKey] as int
      );

  // static String urlFiltersToString(List<String> urlFilters) {
  //   return urlFilters.join("\n");
  // }
}
