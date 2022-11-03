class AppearanceSetting {
  bool showFrequencyTags;
  String pitchAccentStyleString;

  AppearanceSetting({
    required this.showFrequencyTags,
    required this.pitchAccentStyleString,
  });

  factory AppearanceSetting.fromMap(Map<String, Object?> map) =>
      AppearanceSetting(
          showFrequencyTags:
              (map['show_frequency_tags'] as String) == "1" ? true : false,
          pitchAccentStyleString: map['pitch_accent_display_style'] as String);
}
