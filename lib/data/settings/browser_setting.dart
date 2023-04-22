class BrowserSetting {
  bool enableAdBlock;
  List<String> urlFilters;

  // keys for Database
  static const String enableAdBlockKey = 'enable_ad_block';
  static const String urlFiltersKey = 'url_filters';

  BrowserSetting({required this.enableAdBlock, required this.urlFilters});

  factory BrowserSetting.fromMap(Map<String, Object?> map) => BrowserSetting(
      enableAdBlock: (map[enableAdBlockKey] as String) == "1",
      urlFilters: (map[urlFiltersKey] as String).split("\n"));

  static String urlFiltersToString(List<String> urlFilters) {
    return urlFilters.join("\n");
  }
}
