import 'package:immersion_reader/dictionary/dictionary_entry.dart';

class TranslatorDeinflection {
  String originalText;
  String transformedText;
  String deinflectedText;
  int rules;
  List<String> reasons;
  List<DictionaryEntry> databaseEntries;
  TranslatorDeinflection({
    required this.originalText,
    required this.transformedText,
    required this.deinflectedText,
    required this.rules,
    required this.reasons,
    required this.databaseEntries,
  });
}
