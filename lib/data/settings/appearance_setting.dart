class AppearanceSetting {
  bool showFrequencyTags;
  bool enableSlideAnimation;
  String pitchAccentStyleString;
  String popupDictionaryThemeString;

  AppearanceSetting(
      {required this.showFrequencyTags,
      required this.enableSlideAnimation,
      required this.pitchAccentStyleString,
      required this.popupDictionaryThemeString});

  factory AppearanceSetting.fromMap(Map<String, Object?> map) =>
      AppearanceSetting(
          showFrequencyTags:
              (map['show_frequency_tags'] as String) == "1" ? true : false,
          enableSlideAnimation:
              (map['enable_slide_animation'] as String) == "1" ? true : false,
          pitchAccentStyleString: map['pitch_accent_display_style'] as String,
          popupDictionaryThemeString: map['popup_dictionary_theme'] as String);
}
