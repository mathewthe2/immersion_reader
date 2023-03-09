import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyListManager {
  VocabularyListStorage? vocabularyListStorage;

  static final VocabularyListManager _singleton =
      VocabularyListManager._internal();
  VocabularyListManager._internal();

  factory VocabularyListManager.create(
      VocabularyListStorage vocabularyListStorage) {
    _singleton.vocabularyListStorage = vocabularyListStorage;
    return _singleton;
  }

  factory VocabularyListManager() => _singleton;

  List<Vocabulary> get vocabularyList =>
      vocabularyListStorage?.vocabularyListCache ?? [];

  Future<List<Vocabulary>> getVocabularyList() async {
    return await vocabularyListStorage?.getVocabularyItems() ?? [];
  }

  Future<Vocabulary> updateVocabularyItem(
      Vocabulary vocabulary, VocabularyInformationKey key, String value) async {
    return await vocabularyListStorage?.updateVocabularyItem(
            vocabulary, key, value) ??
        vocabulary;
  }

  Future<int> deleteVocabularyItem(Vocabulary vocabulary) async {
    return await vocabularyListStorage
            ?.deleteVocabularyItem(vocabulary.uniqueId) ??
        0;
  }

  Future<int> deleteAllVocabularyItems() async {
    return await vocabularyListStorage?.deleteAllVocabularyItems() ?? 0;
  }
}
