import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary_tool_bar.dart';
import 'package:immersion_reader/widgets/popup_dictionary/vocabulary_tile_list.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class PopupDictionary {
  static final PopupDictionary _singleton = PopupDictionary._internal();
  factory PopupDictionary() => _singleton;
  PopupDictionary._internal();

  Future<void> dismissPopupDictionary() async {
    await SmartDialog.dismiss(force: true);
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
    List<dynamic> popupDictionarySettings = await Future.wait([
      SettingsManager().getPopupDictionaryTheme(),
      SettingsManager().getIsEnabledSlideAnimation(),
      SettingsManager().getAllowLookupWhilePopupActive(),
    ]);
    PopupDictionaryThemeData popupDictionaryThemeData =
        PopupDictionaryThemeData(
            popupDictionaryTheme: popupDictionarySettings[0]);
    bool enableSlideAnimation = popupDictionarySettings[1];
    bool allowLookupWhilePopupActive = popupDictionarySettings[2];
    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        usePenetrate: allowLookupWhilePopupActive,
        permanent: allowLookupWhilePopupActive,
        keepSingle: true,
        animationTime: Duration(milliseconds: enableSlideAnimation ? 200 : 0),
        nonAnimationTypes: [SmartNonAnimationType.continueKeepSingle],
        builder: (context) {
          return Container(
              decoration: BoxDecoration(
                  color: popupDictionaryThemeData
                      .getColor(DictionaryColor.backgroundColor),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15))),
              height: MediaQuery.of(context).size.height * .40,
              child: Column(children: [
                PopupDictionaryToolBar(
                    dismissPopupDictionary: () =>
                        SmartDialog.dismiss(force: true),
                    backgroundColor: popupDictionaryThemeData
                        .getColor(DictionaryColor.backgroundColor)),
                Expanded(
                    child: CupertinoScrollbar(
                        child: SingleChildScrollView(
                            child: VocabularyTileList(
                                text: text,
                                targetIndex: index,
                                popupDictionaryThemeData:
                                    popupDictionaryThemeData,
                                vocabularyList: const []))))
              ]));
        });
  }
}
