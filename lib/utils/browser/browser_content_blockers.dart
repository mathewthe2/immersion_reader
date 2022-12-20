import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserContentBlockers {
  
  // list of Ad URL filters to be used to block ads loading.
  // final adUrlFilters = [
  //   ".*.doubleclick.net/.*",
  //   ".*.ads.pubmatic.com/.*",
  //   ".*.googlesyndication.com/.*",
  //   ".*.google-analytics.com/.*",
  //   ".*.adservice.google.*/.*",
  //   ".*.adbrite.com/.*",
  //   ".*.exponential.com/.*",
  //   ".*.quantserve.com/.*",
  //   ".*.scorecardresearch.com/.*",
  //   ".*.zedo.com/.*",
  //   ".*.adsafeprotected.com/.*",
  //   ".*.teads.tv/.*",
  //   ".*.outbrain.com/.*"
  // ];

  static List<ContentBlocker> getContentBlockers(List<String> adUrlFilters) {
    List<ContentBlocker> contentBlockers = [];
    // for each Ad URL filter, add a Content Blocker to block its loading.
    for (final adUrlFilter in adUrlFilters) {
      contentBlockers.add(ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: adUrlFilter,
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.BLOCK,
          )));
    }

    // apply the "display: none" style to some HTML elements
    contentBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: ".banner, .banners, .ads, .ad, .advert")));
    return contentBlockers;
  }
}
