import 'package:immersion_reader/dictionary/dictionary_options.dart';

class GeneralSetting {
  static const LookupLanguage defaultLookupLanguage = LookupLanguage.ja;
  LookupLanguage lookupLanguage;

  GeneralSetting({this.lookupLanguage = defaultLookupLanguage});

  static const String lookupLanguageKey = 'lookup_language';

  factory GeneralSetting.fromMap(Map<String, Object?> map) => GeneralSetting(
    lookupLanguage: LookupLanguage.values.byName(
      map[lookupLanguageKey] as String,
    ),
  );
}
