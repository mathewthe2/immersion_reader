import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/widgets/popup_dictionary/dialog/popup_dictionary_tool_bar.dart';
import 'package:immersion_reader/widgets/popup_dictionary/dictionary/pop_dictionary_content.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/widgets/popup_dictionary/subtitles/popup_dictionary_subtitles.dart';

class PopupDictionary {
  static final PopupDictionary _singleton = PopupDictionary._internal();
  PopupDictionary._internal();

  factory PopupDictionary() => _singleton;

  Future<void> dismissPopupDictionary() async {
    await SmartDialog.dismiss(force: true);
  }

  static Future<void> warmUp() async {
    getPopupDictionarySettings();
  }

  // loads settings to cache
  static Future<List<dynamic>> getPopupDictionarySettings() async {
    return await Future.wait([
      SettingsManager().getPopupDictionaryTheme(),
      SettingsManager().getIsEnabledSlideAnimation(),
      SettingsManager().getIsEnabledLookupHighlight(),
      SettingsManager().getAllowLookupWhilePopupActive(),
    ]);
  }

  Future<void> showVocabularyList(
      {required String text,
      required int characterIndex,
      required VoidCallback onDismiss,
      String? subtitleId}) async {
    if (characterIndex < 0 || characterIndex >= text.length) {
      await dismissPopupDictionary();
      return;
    }
    // move index by one if initial click on space
    if (text[characterIndex].trim().isEmpty && text.length > characterIndex) {
      characterIndex += 1;
    }
    List<dynamic> popupDictionarySettings = await getPopupDictionarySettings();
    PopupDictionaryThemeData popupDictionaryThemeData =
        PopupDictionaryThemeData(
            popupDictionaryTheme: popupDictionarySettings[0]);
    bool enableSlideAnimation =
        Platform.isIOS ? popupDictionarySettings[1] : false;
    bool enableLookupHighlight = popupDictionarySettings[2];
    bool allowLookupWhilePopupActive = popupDictionarySettings[3];

    // final iconList = [CupertinoIcons.add, CupertinoIcons.alarm];
    // final _bottomNavIndex = 0;

    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        usePenetrate: allowLookupWhilePopupActive,
        permanent: allowLookupWhilePopupActive,
        keepSingle: true,
        onDismiss: () {
          ReaderJsManager().removeHighlight();
          onDismiss();
        },
        maskColor: CupertinoColors.transparent, // hide mask
        animationTime: Duration(milliseconds: enableSlideAnimation ? 200 : 0),
        nonAnimationTypes: [SmartNonAnimationType.continueKeepSingle],
        builder: (context) {
          return Dismissible(
              direction: DismissDirection.down,
              key: UniqueKey(),
              resizeDuration: Duration(milliseconds: 100),
              onDismissed: (_) => SmartDialog.dismiss(),
              child: Container(
                  decoration: BoxDecoration(
                      color: popupDictionaryThemeData
                          .getColor(DictionaryColor.backgroundColor),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15))),
                  height: context.popup(),
                  child: HeroControllerScope.none(
                      child: CupertinoTabScaffold(
                          tabBar: CupertinoTabBar(
                            // onTap: (newIndex) =>
                            //     sharedPreferences?.setInt(tabPreferenceKey, newIndex),
                            // currentIndex:
                            //     sharedPreferences?.getInt(tabPreferenceKey) ?? 0,
                            currentIndex: 0,
                            items: const <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                  icon: Icon(CupertinoIcons.folder_open),
                                  label: 'Dictionary'),
                              BottomNavigationBarItem(
                                  icon: Icon(
                                    CupertinoIcons.doc_text_search,
                                  ),
                                  label: 'Subtitles'),
                            ],
                          ),
                          tabBuilder: (BuildContext context, int tabIndex) {
                            return Column(children: [
                              PopupDictionaryToolBar(
                                  dismissPopupDictionary:
                                      dismissPopupDictionary,
                                  backgroundColor:
                                      popupDictionaryThemeData.getColor(
                                          DictionaryColor.backgroundColor)),
                              Expanded(child: CupertinoTabView(
                                  builder: (BuildContext context) {
                                switch (tabIndex) {
                                  case 0:
                                    return PopupDictionaryContent(
                                      text: text,
                                      popupDictionaryThemeData:
                                          popupDictionaryThemeData,
                                      enableLookupHighlight:
                                          enableLookupHighlight,
                                      characterIndex: characterIndex,
                                    );
                                  case 1:
                                    return PopupDictionarySubtitles(
                                        subtitleId: subtitleId);
                                }
                                return Container();
                              }))
                            ]);
                          }))));
        });
  }
}
