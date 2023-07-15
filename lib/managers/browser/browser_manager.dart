import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:immersion_reader/data/settings/browser/browser_setting.dart';
import 'package:immersion_reader/data/settings/browser/dark_reader_setting.dart';
import 'package:immersion_reader/data/settings/settings_data.dart';
import 'package:immersion_reader/storage/browser_storage.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class BrowserManager {
  BrowserStorage? browserStorage;
  SettingsStorage? settingsStorage;
  List<BrowserBookmark> bookmarks = [];

  static final BrowserManager _singleton = BrowserManager._internal();
  BrowserManager._internal();

  factory BrowserManager.create(
      BrowserStorage browserStorage, SettingsStorage settingsStorage) {
    _singleton.browserStorage = browserStorage;
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  factory BrowserManager() => _singleton;

  Future<List<BrowserBookmark>> getBookmarks() async {
    return await browserStorage?.getBookmarks() ?? [];
  }

  Future<void> addBookmarkWithUrl(BrowserBookmark bookmark) async {
    if (browserStorage != null) {
      await browserStorage!.addBookmark(bookmark);
    }
  }

  Future<void> deleteBookmark(int bookmarkId) async {
    await browserStorage?.deleteBookmark(bookmarkId);
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

  Future<void> toggleEnableDarkReader(bool enableDarkReader) async {
    await settingsStorage!.changeConfigSettings(
        BrowserSetting.enableDarkReaderKey, enableDarkReader ? "1" : "0",
        onSuccessCallback: () => settingsStorage!
            .settingsCache!.browserSetting.enableDarkReader = enableDarkReader);
  }

  Future<void> updateDarkReaderSettings(
      DarkReaderSetting darkReaderSetting) async {
    await settingsStorage!.changeConfigSettings(
        BrowserSetting.darkReaderSettingKey, darkReaderSetting.toString(),
        onSuccessCallback: () => settingsStorage!.settingsCache!.browserSetting
            .darkReaderSetting = darkReaderSetting);
  }

  Future<void> updateUrlFilters(List<String> urlFilters) async {
    await settingsStorage!.changeConfigSettings(BrowserSetting.urlFiltersKey,
        BrowserSetting.urlFiltersToString(urlFilters),
        onSuccessCallback: () => settingsStorage!
            .settingsCache!.browserSetting.urlFilters = urlFilters);
  }
}
