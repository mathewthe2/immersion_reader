import 'package:immersion_reader/languages/korean/korean_utils.dart';

import 'korean_deinflect_rule.dart';

class KoreanDeinflection {
  String term;
  int rules;
  List<String> reasons;

  KoreanDeinflection({
    required this.term,
    required this.rules,
    required this.reasons,
  });
}

class Variant {
  String kanaIn;
  String kanaOut;
  int rulesIn;
  int rulesOut;
  Variant({
    required this.kanaIn,
    required this.kanaOut,
    required this.rulesIn,
    required this.rulesOut,
  });
}

class NormalizedReason {
  String reason;
  List<Variant> variants;
  NormalizedReason({required this.variants, required this.reason});
}

// Ported from Javascript to Dart by Mathew Chan
// https://github.com/FooSoft/yomichan/blob/89ac85afd03e62818624b507c91569edbec54f3d/ext/js/language/deinflector.js
class KoreanDeinflector {
  List<KoreanDeinflection> deinflect(String source) {
    List<KoreanDeinflection> results = [
      KoreanDeinflection(term: source, rules: 0, reasons: []),
    ];
    for (int i = 0; i < results.length; ++i) {
      KoreanDeinflection result = results[i];
      final decomposedTerm = KoreanUtils.disassembleToString(result.term);
      for (NormalizedReason normalizedReason in normalizeReasons(
        deinflectRules,
      )) {
        for (Variant variant in normalizedReason.variants) {
          if ((result.rules != 0 && (result.rules & variant.rulesIn) == 0) ||
              !decomposedTerm.endsWith(variant.kanaIn) ||
              (decomposedTerm.length -
                      variant.kanaIn.length +
                      variant.kanaOut.length) <=
                  0) {
            continue;
          }

          final composedTerm = KoreanUtils.assembleFromString(
            decomposedTerm.substring(
                  0,
                  decomposedTerm.length - variant.kanaIn.length,
                ) +
                variant.kanaOut,
          );

          results.add(
            KoreanDeinflection(
              term: composedTerm,
              rules: variant.rulesOut,
              reasons: [normalizedReason.reason, ...result.reasons],
            ),
          );
        }
      }
    }
    return results;
  }

  List<NormalizedReason> normalizeReasons(reasons) {
    List<NormalizedReason> normalizedReasons = [];
    for (MapEntry<String, List<KoreanDeinflectRule>> reasons
        in deinflectRules.entries) {
      List<Variant> variants = reasons.value
          .map(
            (KoreanDeinflectRule rule) => Variant(
              kanaIn: rule.kanaIn,
              kanaOut: rule.kanaOut,
              rulesIn: rulesToRuleFlags(rule.rulesIn),
              rulesOut: rulesToRuleFlags(rule.rulesOut),
            ),
          )
          .toList();
      normalizedReasons.add(
        NormalizedReason(reason: reasons.key, variants: variants),
      );
    }
    return normalizedReasons;
  }

  int rulesToRuleFlags(List<String> rules) {
    int value = 0;
    for (String rule in rules) {
      value |= _ruleTypes[rule] ?? 0;
    }
    return value;
  }

  // https://github.com/Lyroxide/yomichan-korean/blob/a9280ea2f4ef3b20d5aaedadb7e629f0761987af/ext/js/language/deinflector.js
  final Map<String, int> _ruleTypes = {
    'v': 1, // Verbs to match in dict json schema
    'adj': 2, // Adjectives to match in dict json schema
    'b': 4, // conjugated base that can be further conjugated
  };
}
