import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/widgets/common/down_only_scroll_view.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary_tool_bar.dart';
import 'package:immersion_reader/widgets/popup_dictionary/vocabulary_tile_list.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/widgets/reader/highlight_controller.dart';

class PopupDictionary {
  HighlightController? highlightController;

  static final PopupDictionary _singleton = PopupDictionary._internal();
  PopupDictionary._internal();

  factory PopupDictionary.create({HighlightController? highlightController}) {
    _singleton.highlightController = highlightController;
    return _singleton;
  }

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

  Future<void> showVocabularyList(String text, int index) async {
    if (index < 0 || index >= text.length) {
      await dismissPopupDictionary();
      return;
    }
    // move index by one if initial click on space
    if (text[index].trim().isEmpty && text.length > index) {
      index += 1;
    }
    List<dynamic> popupDictionarySettings = await getPopupDictionarySettings();
    PopupDictionaryThemeData popupDictionaryThemeData =
        PopupDictionaryThemeData(
            popupDictionaryTheme: popupDictionarySettings[0]);
    bool enableSlideAnimation = popupDictionarySettings[1];
    bool enableLookupHighlight = popupDictionarySettings[2];
    bool allowLookupWhilePopupActive = popupDictionarySettings[3];

    void onTapCharacterCallback(initialOffset, textLength) {
      if (enableLookupHighlight) {
        highlightController?.highlightLastSelected(initialOffset, textLength);
      }
    }

    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        usePenetrate: allowLookupWhilePopupActive,
        permanent: allowLookupWhilePopupActive,
        keepSingle: true,
        onDismiss: () => highlightController?.removeHighlight(),
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
                  height: context.screenHeight * 0.4,
                  child: Column(children: [
                    PopupDictionaryToolBar(
                        dismissPopupDictionary: dismissPopupDictionary,
                        backgroundColor: popupDictionaryThemeData
                            .getColor(DictionaryColor.backgroundColor)),
                    Expanded(
                        child: CupertinoScrollbar(
                            child: SingleChildScrollView(
                                child: VocabularyTileList(
                                    text: text,
                                    targetIndex: index,
                                    onTapCharacterCallback:
                                        onTapCharacterCallback,
                                    removeHighlight:
                                        highlightController?.removeHighlight,
                                    popupDictionaryThemeData:
                                        popupDictionaryThemeData,
                                    vocabularyList: const []))))
                  ])));
        });
  }
}
