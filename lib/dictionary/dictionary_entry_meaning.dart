import 'package:immersion_reader/dictionary/dictionary_entry_id.dart';

class DictionaryEntryMeaning {
  List<String> meanings;
  DictionaryEntryId? redirectQuery;
  DictionaryEntryMeaning({required this.meanings, this.redirectQuery});
}
