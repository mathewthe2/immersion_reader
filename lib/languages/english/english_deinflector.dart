import 'package:immersion_reader/languages/english/english_tokenizer.dart';

const String dataPath = 'assets/dictionary/wordforms.json';

class EnglishDeinflector {
  late Map<String, String> wordForms;
  static int wordExpansionLimit = 2; // limit of individual words to deinflect

  static final EnglishDeinflector _singleton = EnglishDeinflector._internal();
  EnglishDeinflector._internal();

  static EnglishDeinflector create(Map<String, String> wordForms) {
    _singleton.wordForms = wordForms;
    return _singleton;
  }

  List<String> _deinflectWord(String word) {
    if (wordForms.containsKey(word)) {
      return [wordForms[word]!];
    }
    return [];
  }

  List<String> _expandPhrase(String phrase) {
    final words = phrase.split(' ');
    List<List<String>> options = [];

    for (final word in words) {
      final forms = <String>{};

      // Always include original first
      forms.add(word);

      // Add deinflected forms
      forms.addAll(_deinflectWord(word));

      // ✅ Cap expansion (preserve order)
      final limited = forms.take(wordExpansionLimit).toList();

      options.add(limited);
    }

    // Cartesian product
    List<String> results = [''];
    for (final wordOptions in options) {
      List<String> newResults = [];
      for (final prefix in results) {
        for (final option in wordOptions) {
          newResults.add(prefix.isEmpty ? option : '$prefix $option');
        }
      }
      results = newResults;
    }

    return results;
  }

  List<String> deinflectText(String source) {
    final candidates = EnglishTokenizer.splitIntoCandidates(source);
    final results = <String>[];
    final seen = <String>{};

    for (final candidate in candidates) {
      final local = <String>[];

      // 1. deinflected phrases
      if (wordForms.containsKey(candidate)) {
        local.add(wordForms[candidate]!);
      }

      // 2. phrase expansion
      final expanded = _expandPhrase(candidate);
      for (final e in expanded) {
        if (e != candidate) {
          local.add(e);
        }
      }

      // 3. original LAST
      local.add(candidate);

      // 4. dedupe but preserve order
      for (final item in local) {
        if (!seen.contains(item)) {
          seen.add(item);
          results.add(item);
        }
      }
    }

    return results;
  }
}
