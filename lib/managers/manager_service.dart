import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/storage/storage_provider.dart';
import 'package:immersion_reader/managers/browser/browser_manager.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/managers/profile/profile_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/managers/vocabulary_list/vocabulary_list_manager.dart';
import 'package:immersion_reader/storage/browser_storage.dart';
import 'package:immersion_reader/storage/profile_storage.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';

class ManagerService {
  static const managers = [
    BookManager,
    BrowserManager,
    DictionaryManager,
    ProfileManager,
    SettingsManager,
    VocabularyListManager
  ];

  static void setupAll(StorageProvider storageProvider) {
    for (Type manager in managers) {
      _setupManager(manager, storageProvider);
    }
  }

  static void _setupManager(Type manager, StorageProvider storageProvider) {
    switch (manager) {
      case const (BookManager):
        BookManager.create(
            storageProvider.storage(SettingsStorage) as SettingsStorage);
        break;
      case const (BrowserManager):
        BrowserManager.create(
            storageProvider.storage(BrowserStorage) as BrowserStorage,
            storageProvider.storage(SettingsStorage) as SettingsStorage);
        break;
      case const (DictionaryManager):
        DictionaryManager.create(
            storageProvider.storage(SettingsStorage) as SettingsStorage);
        break;
      case const (ProfileManager):
        ProfileManager.create(
            storageProvider.storage(ProfileStorage) as ProfileStorage);
        break;
      case const (SettingsManager):
        SettingsManager.create(
            storageProvider.storage(SettingsStorage) as SettingsStorage);
        break;
      case const (VocabularyListManager):
        VocabularyListManager.create(storageProvider
            .storage(VocabularyListStorage) as VocabularyListStorage);
        break;
    }
  }
}
