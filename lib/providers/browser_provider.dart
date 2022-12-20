import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:immersion_reader/data/settings/browser_setting.dart';
import 'package:immersion_reader/data/settings/settings_data.dart';
import 'package:immersion_reader/pages/browser.dart';
import 'package:immersion_reader/storage/browser_storage.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class BrowserProvider {
  BrowserStorage? browserStorage;
  SettingsStorage? settingsStorage;
  List<BrowserBookmark> bookmarks = [];

  BrowserProvider._create() {
    // print("_create() (private constructor)");
  }

  static Future<BrowserProvider> create(SettingsStorage settingsStorage) async {
    BrowserProvider provider = BrowserProvider._create();
    provider.browserStorage = await BrowserStorage.create();
    provider.settingsStorage = settingsStorage;
    return provider;
  }

  Future<List<BrowserBookmark>> getBookmarks() async {
    if (browserStorage == null) {
      return [];
    }
    bookmarks = await browserStorage!.getBookmarks();
    return bookmarks;
  }

  Future<void> addBookmarkWithUrl(BrowserBookmark bookmark) async {
    if (browserStorage != null) {
      await browserStorage!.addBookmark(bookmark);
    }
  }

  Future<void> deleteBookmark(int bookmarkId) async {
    if (browserStorage != null) {
      await browserStorage!.deleteBookmark(bookmarkId);
    }
  }

  Future<BrowserSetting> getBrowserSettings() async {
    SettingsData settingsData = await settingsStorage!.getConfigSettings();
    return settingsData.browserSetting;
  }

  Future<void> toggleEnableAdBlock(bool enableAdBlock) async {
    await settingsStorage!.changeConfigSettings(
        BrowserSetting.enableAdBlockKey, enableAdBlock ? "1" : "0",
        onSuccessCallback: () => settingsStorage!
            .settingsCache!.browserSetting.enableAdBlock = enableAdBlock);
  }

  Future<void> updateUrlFilters(List<String> urlFilters) async {
    await settingsStorage!.changeConfigSettings(BrowserSetting.urlFiltersKey,
        BrowserSetting.urlFiltersToString(urlFilters),
        onSuccessCallback: () => settingsStorage!
            .settingsCache!.browserSetting.urlFilters = urlFilters);
  }
}
