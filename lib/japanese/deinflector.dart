import './deinflect_rule.dart';

class Deinflection {
  String term;
  int rules;
  List<String> reasons;

  Deinflection(
      {required this.term, required this.rules, required this.reasons});
}

class Variant {
  String kanaIn;
  String kanaOut;
  int rulesIn;
  int rulesOut;
  Variant(
      {required this.kanaIn,
      required this.kanaOut,
      required this.rulesIn,
      required this.rulesOut});
}

class NormalizedReason {
  String reason;
  List<Variant> variants;
  NormalizedReason({required this.variants, required this.reason});
}

// Ported from Javascript to Dart by Mathew Chan
// https://github.com/FooSoft/yomichan/blob/89ac85afd03e62818624b507c91569edbec54f3d/ext/js/language/deinflector.js
class Deinflector {
  List<Deinflection> deinflect(String source) {
    List<Deinflection> results = [
      Deinflection(term: source, rules: 0, reasons: [])
    ];
    for (int i = 0; i < results.length; ++i) {
      Deinflection result = results[i];
      for (NormalizedReason normalizedReason
          in normalizeReasons(deinflectRules)) {
        for (Variant variant in normalizedReason.variants) {
          if ((result.rules != 0 && (result.rules & variant.rulesIn) == 0) ||
              !result.term.endsWith(variant.kanaIn) ||
              (result.term.length -
                      variant.kanaIn.length +
                      variant.kanaOut.length) <=
                  0) {
            continue;
          }

          results.add(Deinflection(
              term: result.term.substring(
                      0, result.term.length - variant.kanaIn.length) +
                  variant.kanaOut,
              rules: variant.rulesOut,
              reasons: [normalizedReason.reason, ...result.reasons]));
        }
      }
    }
    return results;
  }

  List<NormalizedReason> normalizeReasons(reasons) {
    List<NormalizedReason> normalizedReasons = [];
    for (MapEntry<String, List<DeinflectRule>> reasons
        in deinflectRules.entries) {
      List<Variant> variants = reasons.value
          .map((DeinflectRule rule) => Variant(
              kanaIn: rule.kanaIn,
              kanaOut: rule.kanaOut,
              rulesIn: rulesToRuleFlags(rule.rulesIn),
              rulesOut: rulesToRuleFlags(rule.rulesOut)))
          .toList();
      normalizedReasons
          .add(NormalizedReason(reason: reasons.key, variants: variants));
    }
    return normalizedReasons;
  }

  int rulesToRuleFlags(List<String> rules) {
    int value = 0;
    for (String rule in rules) {
      String baseRule = _extractBaseRule(rule);
      value |= _ruleTypes[baseRule] ?? 0;
    }
    return value;
  }

  // v5 -> v5
  // v5r -> v5
  // v1s -> v1
  String _extractBaseRule(String rule) {
    if (_ruleTypes.containsKey(rule)) {
      return rule;
    } else if (rule.length >= 2 &&
        _ruleTypes.containsKey(rule.substring(0, 2))) {
      // v1, v5, vs, vk, vz
      return rule.substring(0, 2);
    } else if (rule.length >= 3 &&
        _ruleTypes.containsKey(rule.substring(0, 3))) {
      // iru
      return rule.substring(0, 3);
    } else if (rule.length >= 5 &&
        _ruleTypes.containsKey(rule.substring(0, 5))) {
      // adj-i
      return rule.substring(0, 5);
    }
    return rule;
  }

  // unmatched rules - not sure how to handle
  // vt, vi

  final Map<String, int> _ruleTypes = {
    'v1': 1, // Verb ichidan
    'v5': 2, // Verb godan
    'vs': 4, // Verb suru
    'vk': 8, // Verb kuru
    'vz': 16, // Verb zuru
    'adj-i': 32, // Adjective i
    'iru': 64 // Intermediate -iru endings for progressive or perfect tense
  };
}
