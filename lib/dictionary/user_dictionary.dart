import './dictionary_entry.dart';
import './dictionary_meta_entry.dart';

class UserDictionary {
  String dictionaryName;
  List<DictionaryEntry> dictionaryEntries;
  List<DictionaryMetaEntry> dictionaryMetaEntries;

  UserDictionary(
      {required this.dictionaryName,
      required this.dictionaryEntries,
      required this.dictionaryMetaEntries});
}
