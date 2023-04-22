import 'package:flutter/cupertino.dart';

class AppearanceSetting {
  bool showFrequencyTags;
  bool enableSlideAnimation;
  String pitchAccentStyleString;
  String popupDictionaryThemeString;
  bool enableReaderFullScreen;
  bool isKeepScreenOn;
  String readerThemeString;

  AppearanceSetting(
      {required this.showFrequencyTags,
      required this.enableSlideAnimation,
      required this.pitchAccentStyleString,
      required this.popupDictionaryThemeString,
      required this.enableReaderFullScreen,
      required this.isKeepScreenOn,
      required this.readerThemeString});

  static const String showFrequencyTagsKey = 'show_frequency_tags';
  static const String enableSlideAnimationKey = 'enable_slide_animation';
  static const String pitchAccentStyleKey = 'pitch_accent_display_style';
  static const String popupDictionaryThemeKey = 'popup_dictionary_theme';
  static const String enableReaderFullScreenKey = 'enable_full_screen';
  static const String isKeepScreenOnKey = 'keep_screen_on';
  static const String readerThemeKey = 'reader_theme';

  static Map<String, Color> readerThemeBackgroundColorMap = {
    'ecru-theme': const Color(0xfff7f6eb),
    'light-theme': const Color(0xffffffff),
    'black-theme': const Color(0xff000000),
    'gray-theme': const Color(0xff23272a),
    'dark-theme': const Color(0xff121212),
    'water-theme': const Color(0xffdfecf4)
  };

  Color get readerBackgroundColor =>
      readerThemeBackgroundColorMap[readerThemeString] ?? CupertinoColors.white;

  factory AppearanceSetting.fromMap(Map<String, Object?> map) =>
      AppearanceSetting(
          showFrequencyTags: (map[showFrequencyTagsKey] as String) == "1",
          enableSlideAnimation: (map[enableSlideAnimationKey] as String) == "1",
          pitchAccentStyleString: map[pitchAccentStyleKey] as String,
          readerThemeString: map[readerThemeKey] as String,
          popupDictionaryThemeString: map[popupDictionaryThemeKey] as String,
          enableReaderFullScreen:
              (map[enableReaderFullScreenKey] as String) == "1",
          isKeepScreenOn: (map[isKeepScreenOnKey] as String) == "1");
}
