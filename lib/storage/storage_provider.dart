import 'package:collection/collection.dart';
import 'package:immersion_reader/storage/abstract_storage.dart';
import 'package:immersion_reader/storage/browser_storage.dart';
import 'package:immersion_reader/storage/profile_storage.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';

class StorageProvider {
  static const storageTypes = [
    BrowserStorage,
    ProfileStorage,
    SettingsStorage,
    VocabularyListStorage
  ];
  Map<Type, AbstractStorage?>? resultsMap;

  StorageProvider._create();

  static Future<StorageProvider> create() async {
    StorageProvider provider = StorageProvider._create();
    List<AbstractStorage?> results = await Future.wait(
        storageTypes.map((storageType) => AbstractStorage.create(storageType)));
    provider.resultsMap = Map.fromEntries(
        storageTypes.mapIndexed((index, e) => MapEntry(e, results[index])));
    return provider;
  }

  AbstractStorage? storage(Type storage) {
    return resultsMap?[storage];
  }
}
