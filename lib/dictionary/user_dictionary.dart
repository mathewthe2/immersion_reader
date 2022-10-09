import './dictionary_entry.dart';
import './dictionary_meta_entry.dart';
import './dictionary_tag.dart';

class UserDictionary {
  String dictionaryName;
  List<DictionaryEntry> dictionaryEntries;
  List<DictionaryMetaEntry> dictionaryMetaEntries;
  List<DictionaryTag> dictionaryTags;

  UserDictionary(
      {required this.dictionaryName,
      required this.dictionaryEntries,
      required this.dictionaryMetaEntries,
      required this.dictionaryTags});
}
