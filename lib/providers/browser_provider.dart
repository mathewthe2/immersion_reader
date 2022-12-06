import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:immersion_reader/storage/browser_storage.dart';

class BrowserProvider {
  BrowserStorage? browserStorage;
  List<BrowserBookmark> bookmarks = [];

  BrowserProvider._create() {
    // print("_create() (private constructor)");
  }

  static Future<BrowserProvider> create() async {
    BrowserProvider provider = BrowserProvider._create();
    provider.browserStorage = await BrowserStorage.create();
    // provider.vocabularyList = await provider.getVocabularyList();
    return provider;
  }

  Future<List<BrowserBookmark>> getBookmarks() async {
    if (browserStorage == null) {
      return [];
    }
    bookmarks = await browserStorage!.getBookmarks();
    return bookmarks;
  }
}
