import 'package:immersion_reader/japanese/vocabulary.dart';

class SearchResult {
  List<Vocabulary> exactMatches = [];
  List<Vocabulary> additionalMatches = [];
  List<String> existingVocabularyIds = [];

  SearchResult({required this.exactMatches, required this.additionalMatches}) ;
}
