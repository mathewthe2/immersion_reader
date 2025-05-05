import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/utils/system_theme.dart';
import 'package:immersion_reader/widgets/audiobook/audio_book_matching.dart';
import 'package:immersion_reader/widgets/audiobook/audio_book_player.dart';
import 'package:immersion_reader/widgets/audiobook/audio_book_subtitles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioBookDialog {
  static const String audioBookDialogTag = "audio_book_dialog_tag";
  static const String tabPreferenceKey = 'audio_book_dialog_tab';

  static void showDialog(
      {required StreamController<int> matchProgressController,
      required Book book,
      required VoidCallback onDismiss,
      SharedPreferences? sharedPreferences}) {
    SmartDialog.show(
        tag: audioBookDialogTag,
        alignment: Alignment.bottomCenter,
        animationTime: getDialogAnimationTime(),
        maskColor: CupertinoColors.transparent,
        builder: (context) {
          return Dismissible(
              direction: DismissDirection.down,
              key: UniqueKey(),
              resizeDuration: Duration(milliseconds: 100),
              onDismissed: (_) => SmartDialog.dismiss(tag: audioBookDialogTag),
              child: Container(
                  height: context.popupFull(),
                  width: context.screenWidth,
                  color: CupertinoColors.white,
                  child: HeroControllerScope.none(
                      child: CupertinoTabScaffold(
                    tabBar: CupertinoTabBar(
                      onTap: (newIndex) =>
                          sharedPreferences?.setInt(tabPreferenceKey, newIndex),
                      currentIndex:
                          sharedPreferences?.getInt(tabPreferenceKey) ?? 0,
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.folder_open),
                            label: 'Subtitle Matcher'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.headphones),
                            label: 'Player'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.doc_text_search),
                            label: 'Subtitles'),
                      ],
                    ),
                    tabBuilder: (BuildContext context, int index) {
                      return CupertinoTabView(
                        builder: (BuildContext context) {
                          switch (index) {
                            case 0:
                              return AudioBookMatching(
                                  matchProgressController:
                                      matchProgressController,
                                  book: book);
                            case 1:
                              return AudioBookPlayer(
                                book: book,
                              );
                            case 2:
                              return AudioBookSubtitles(book: book);
                            default:
                              return AudioBookPlayer(
                                book: book,
                              );
                          }
                        },
                      );
                    },
                  ))));
        },
        onDismiss: onDismiss);
  }
}
