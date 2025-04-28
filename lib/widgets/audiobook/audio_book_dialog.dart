import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/widgets/audiobook/audio_book_matching.dart';
import 'package:immersion_reader/widgets/audiobook/audio_book_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioBookDialog {
  static const String tabPreferenceKey = 'audio_book_dialog_tab';

  static void showDialog(
      {required StreamController<int> matchProgressController,
      required Book book,
      required VoidCallback onDismiss,
      required Function(String) reopenReader,
      SharedPreferences? sharedPreferences}) {
    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        builder: (context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
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
                        icon: Icon(CupertinoIcons.headphones), label: 'Player'),
                  ],
                ),
                tabBuilder: (BuildContext context, int index) {
                  return CupertinoTabView(
                    builder: (BuildContext context) {
                      if (index == 0) {
                        return AudioBookMatching(
                            matchProgressController: matchProgressController,
                            reopenReader: reopenReader,
                            book: book);
                      }
                      return AudioBookPlayer(
                        book: book,
                      );
                    },
                  );
                },
              )));
        },
        onDismiss: onDismiss);
  }
}
