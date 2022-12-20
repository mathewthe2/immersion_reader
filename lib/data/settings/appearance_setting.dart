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

  static const String showFrequencyTagsKey = 'show_frequency_tags';
  static const String enableSlideAnimationKey = 'enable_slide_animation';
  static const String pitchAccentStyleKey = 'pitch_accent_display_style';
  static const String popupDictionaryThemeKey = 'popup_dictionary_theme';

  factory AppearanceSetting.fromMap(Map<String, Object?> map) =>
      AppearanceSetting(
          showFrequencyTags:
              (map[showFrequencyTagsKey] as String) == "1" ? true : false,
          enableSlideAnimation:
              (map[enableSlideAnimationKey] as String) == "1" ? true : false,
          pitchAccentStyleString: map[pitchAccentStyleKey] as String,
          popupDictionaryThemeString: map[popupDictionaryThemeKey] as String);
}
