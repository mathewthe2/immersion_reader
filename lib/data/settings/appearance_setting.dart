class AppearanceSetting {
  bool showFrequencyTags;
  String pitchAccentDisplayStyle;

  AppearanceSetting({
    required this.showFrequencyTags,
    required this.pitchAccentDisplayStyle,
  });

  factory AppearanceSetting.fromMap(Map<String, Object?> map) =>
      AppearanceSetting(
          showFrequencyTags:
              (map['show_frequency_tags'] as String) == "1" ? true : false,
          pitchAccentDisplayStyle: map['pitch_accent_display_style'] as String);
}
