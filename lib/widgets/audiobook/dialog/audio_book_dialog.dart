import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/utils/system_theme.dart';
import 'package:immersion_reader/widgets/audiobook/dialog/audio_book_dialog_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioBookDialog {
  static const String audioBookDialogTag = "audio_book_dialog_tag";
  static const String tabPreferenceKey = 'audio_book_dialog_tab';

  static void showDialog(
      {required StreamController<int> matchProgressController,
      required Book book,
      required VoidCallback onDismiss,
      SharedPreferences? sharedPreferences,
      int? initialTabIndex}) {
    SmartDialog.show(
        tag: audioBookDialogTag,
        alignment: Alignment.bottomCenter,
        animationTime: getDialogAnimationTime(),
        maskColor: CupertinoColors.transparent,
        builder: (context) {
          return AudioBookDialogContent(
              sharedPreferences: sharedPreferences,
              book: book,
              matchProgressController: matchProgressController);
        },
        onDismiss: onDismiss);
  }
}
