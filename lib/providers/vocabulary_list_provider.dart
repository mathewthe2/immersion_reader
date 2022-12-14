import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyListProvider {
  VocabularyListStorage? vocabularyListStorage;
  List<Vocabulary> vocabularyList = [];

  VocabularyListProvider._create() {
    // print("_create() (private constructor)");
  }

  static Future<VocabularyListProvider> create() async {
    VocabularyListProvider provider = VocabularyListProvider._create();
    provider.vocabularyListStorage = await VocabularyListStorage.create();
    provider.vocabularyList = await provider.getVocabularyList();
    return provider;
  }

  Future<List<Vocabulary>> getVocabularyList() async {
    if (vocabularyListStorage == null) {
      return [];
    }
    vocabularyList = await vocabularyListStorage!.getVocabularyItems();
    return vocabularyList;
  }

  Future<Vocabulary> updateVocabularyItem(
      Vocabulary vocabulary, VocabularyInformationKey key, String value) async {
    Vocabulary updatedVocabulary = await vocabularyListStorage!
        .updateVocabularyItem(vocabulary, key, value);
    int index = vocabularyList.indexOf(vocabulary);
    if (index >= 0 && index < vocabularyList.length) {
      vocabularyList[index] = updatedVocabulary;
    }
    return updatedVocabulary;
  }

  Future<int> deleteVocabularyItem(Vocabulary vocabulary) async {
    int count = await vocabularyListStorage!
        .deleteVocabularyItem(vocabulary.getIdentifier());
    vocabularyList = List.from(vocabularyList)..remove(vocabulary);
    return count;
  }

  Future<int> deleteAllVocabularyItems() async {
    int count = await vocabularyListStorage!.deleteAllVocabularyItems();
    vocabularyList = [];
    return count;
  }
}
