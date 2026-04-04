import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/japanese/dictionary.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/languages/abstract_translator.dart';
import 'package:immersion_reader/languages/english/english_deinflector.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class EnglishTranslator extends AbstractTranslator {
  late Dictionary dictionary;
  late EnglishDeinflector deinflector;

  SettingsStorage? settingsStorage;

  static final EnglishTranslator _singleton = EnglishTranslator._internal();
  EnglishTranslator._internal();

  static EnglishTranslator create(
    SettingsStorage settingsStorage, {
    Map<String, String> wordForms = const {},
  }) {
    _singleton.dictionary = Dictionary.create(settingsStorage);
    _singleton.deinflector = EnglishDeinflector.create(wordForms);
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  @override
  Future<void> loadWordForms() async {
    ByteData bytes = await rootBundle.load(
      p.join("assets", "languages", "english", "wordForms.json"),
    );
    String jsonStr = const Utf8Decoder().convert(bytes.buffer.asUint8List());
    Map<String, String> json = Map<String, String>.from(jsonDecode(jsonStr));
    deinflector.wordForms = json;
  }

  @override
  Future<SearchResult> findTermForUserSearch(
    String text, {
    DictionaryOptions? options,
  }) async {
    return SearchResult(exactMatches: [], additionalMatches: []);
  }

  // String clean(String text) {
  //   return text.trim().toLowerCase();
  // }

  @override
  Future<List<Vocabulary>> findTerm(
    String text, {
    bool wildcards = false,
    String reading = '',
    DictionaryOptions? options,
  }) async {
    options ??= DictionaryOptions();
    List<String> uniqueDeinflectionTerms = deinflector.deinflectText(text);
    List<DictionaryEntry> entries = await dictionary.findTermsBulk(
      uniqueDeinflectionTerms,
      isHaveDisabledDictionaries: options.disabledDictionaryIds.isNotEmpty,
      isOrdered: true,
    );

    List<Vocabulary> definitions = await dictionary.getVocabularyBatch(entries);

    return definitions;
  }
}
