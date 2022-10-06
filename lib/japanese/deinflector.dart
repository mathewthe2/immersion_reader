import './deinflect_rule.dart';

typedef ValidateFunction = Future<List<List<String>>> Function(String term);

class Deinflection {
  String term;
  List<String> tags;
  String rule;
  List<Deinflection> children = [];

  Deinflection({required this.term, this.tags = const [], this.rule = ''});

  Future<bool> validate(ValidateFunction validator) async {
    for (List<String> termTags in await validator(term)) {
      if (tags.isEmpty) {
        return true;
      }
      for (String tag in tags) {
        if (termTags.contains(tag)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> deinflect(ValidateFunction validator) async {
    // validate here
    if (await validate(validator)) {
      Deinflection child = Deinflection(term: term, tags: tags);
      children.add(child);
    }

    // deinflect
    for (MapEntry<String, List<DeinflectRule>> rules
        in deinflectRules.entries) {
      for (DeinflectRule variant in rules.value) {
        bool allowed = tags.isEmpty;
        for (String tag in tags) {
          if (variant.tagsIn.contains(tag)) {
            allowed = true;
            break;
          }
        }

        if (!allowed || !term.endsWith(variant.kanaIn)) {
          continue;
        }

        String termEntry =
            term.substring(0, term.length - variant.kanaIn.length) +
                variant.kanaOut;
        Deinflection child = Deinflection(
            term: termEntry, tags: variant.tagsOut, rule: rules.key);

        if (await child.deinflect(validator)) {
          children.add(child);
        }
      }
    }
    return children.isNotEmpty;
  }

  List<DeinflectedTerm> gather() {
    if (children.isEmpty) {
      return [DeinflectedTerm(root: term, tags: tags, rules: [])];
    }
    List<DeinflectedTerm> paths = [];
    for (Deinflection child in children) {
      for (DeinflectedTerm path in child.gather()) {
        if (rule.isNotEmpty) {
          path.rules.add(rule);
        }
        path.source = term;
        paths.add(path);
      }
    }
    return paths;
  }
}

class DeinflectedTerm {
  String root;
  List<String> tags;
  List<String> rules;
  String source = '';
  DeinflectedTerm(
      {required this.root, required this.tags, required this.rules});
}

class Deinflector {
  Future<List<DeinflectedTerm>> deinflect(term, validator) async {
    Deinflection node = Deinflection(term: term);
    if (await node.deinflect(validator)) {
      return node.gather();
    }
    return [];
  }
}
