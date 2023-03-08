import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/providers/profile_provider.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/widgets/popup_dictionary/vocabulary_tile_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PopupDictionary {
  final VocabularyListStorage vocabularyListStorage;
  final ProfileProvider? profileProvider;
  final BuildContext parentContext;

  PopupDictionary(
      {required this.vocabularyListStorage,
      this.profileProvider,
      required this.parentContext});

  Future<void> showVocabularyList(String text, int index) async {
    if (index < 0 || index >= text.length) {
      return;
    }
    // move index by one if initial click on space
    if (text[index].trim().isEmpty && text.length > index) {
      index += 1;
    }
    PopupDictionaryTheme popupDictionaryTheme =
        await DictionaryManager().settingsProvider!.getPopupDictionaryTheme();
    PopupDictionaryThemeData popupDictionaryThemeData =
        PopupDictionaryThemeData(popupDictionaryTheme: popupDictionaryTheme);
    bool enableSlideAnimation =
        await DictionaryManager().settingsProvider!.getIsEnabledSlideAnimation();
    showCupertinoModalBottomSheet<void>(
        duration: Duration(milliseconds: enableSlideAnimation ? 400 : 0),
        context: parentContext,
        builder: (BuildContext context) {
          return SafeArea(
              child: Container(
                  height: MediaQuery.of(context).size.height * .40,
                  color: popupDictionaryThemeData
                      .getColor(DictionaryColor.backgroundColor),
                  child: CupertinoScrollbar(
                      child: SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: VocabularyTileList(
                              text: text,
                              targetIndex: index,
                              popupDictionaryThemeData:
                                  popupDictionaryThemeData,
                              profileProvider: profileProvider,
                              vocabularyList: const [],
                              vocabularyListStorage: vocabularyListStorage)))));
        });
  }
}
