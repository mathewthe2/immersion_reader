enum PitchAccentDisplayStyle { none, graph, number }

enum PopupDictionaryTheme { dark, dracula, light, purple }

enum LookupLanguage { zh, en, ja, ko }

const defaultLookupLanguage = LookupLanguage.ja;

const lookupLanguageStringMap = {
  LookupLanguage.zh: "Chinese (zh)",
  LookupLanguage.en: "English (en)",
  LookupLanguage.ja: "Japanese (ja)",
  LookupLanguage.ko: "Korean (ko)",
};

class DictionaryOptions {
  List<int> disabledDictionaryIds;
  bool isGetFrequencyTags;
  PitchAccentDisplayStyle pitchAccentDisplayStyle;
  PopupDictionaryTheme popupDictionaryTheme;
  LookupLanguage lookupLanguage;

  bool sorted;

  DictionaryOptions({
    this.disabledDictionaryIds = const [],
    this.isGetFrequencyTags = true,
    this.pitchAccentDisplayStyle = PitchAccentDisplayStyle.graph,
    this.popupDictionaryTheme = PopupDictionaryTheme.dark,
    this.lookupLanguage = defaultLookupLanguage,
    this.sorted = true,
  });

  static List<String> lookupLanguageOptions = lookupLanguageStringMap.values
      .toList();

  static String lookupLanguageToString(LookupLanguage lookupLanguage) =>
      lookupLanguageStringMap[lookupLanguage] ??
      lookupLanguageStringMap[defaultLookupLanguage]!;

  static LookupLanguage lookupLanguagefromString(String value) {
    return lookupLanguageStringMap.entries
        .firstWhere(
          (entry) => entry.value == value,
          orElse: () => const MapEntry(defaultLookupLanguage, ''),
        )
        .key;
  }
}
