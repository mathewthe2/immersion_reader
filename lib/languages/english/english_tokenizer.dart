class EnglishTokenizer {
  static List<String> _tokenize(String input) {
    final cleaned = input.toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), ' ');

    final rawWords = cleaned.split(RegExp(r'\s+'));

    final tokens = <String>[];

    for (final word in rawWords) {
      if (word.isEmpty) continue;

      tokens.add(word);

      if (word.contains('-')) {
        tokens.addAll(word.split('-'));
      }
    }

    return tokens;
  }

  static List<String> splitIntoCandidates(String source) {
    if (source.trim().isEmpty) {
      return [];
    }

    final words = _tokenize(source);
    final candidates = <String>[];

    // iterate by starting position first
    for (int start = 0; start < words.length; start++) {
      // from longest → shortest at this position
      for (int end = words.length; end > start; end--) {
        final phrase = words.sublist(start, end).join(' ');
        candidates.add(phrase);
      }
    }

    return candidates;
  }
}
