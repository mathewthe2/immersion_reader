import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:flutter/cupertino.dart';

class PopupDictionaryThemeData {
  PopupDictionaryTheme popupDictionaryTheme;

  PopupDictionaryThemeData({required this.popupDictionaryTheme});

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16)}';
  }

  // dracula color palette
  // https://draculatheme.com/contribute

  Color getBackgroundColor() {
    switch (popupDictionaryTheme) {
      case PopupDictionaryTheme.dark:
        return CupertinoColors.darkBackgroundGray;
      case PopupDictionaryTheme.dracula:
        return const Color(0xFF282a36);
      case PopupDictionaryTheme.light:
        return CupertinoColors.white;
    }
  }

  Color getPrimaryTextColor() {
    switch (popupDictionaryTheme) {
      case PopupDictionaryTheme.dark:
        return CupertinoColors.white;
      case PopupDictionaryTheme.light:
        return CupertinoColors.darkBackgroundGray;
      case PopupDictionaryTheme.dracula:
        return const Color(0xFFF8F8F2);
    }
  }

  Color getSegmentColor() {
    switch (popupDictionaryTheme) {
      case PopupDictionaryTheme.dark:
        return CupertinoColors.white;
      case PopupDictionaryTheme.light:
        return CupertinoColors.darkBackgroundGray;
      case PopupDictionaryTheme.dracula:
        return const Color(0xFFF8F8F2);
    }
  }

  Color getSegmentThumbColor() {
    switch (popupDictionaryTheme) {
      case PopupDictionaryTheme.dark:
        return const Color(0xFF636366);
      case PopupDictionaryTheme.light:
        return CupertinoColors.white;
      case PopupDictionaryTheme.dracula:
        return const Color(0xFF44475A);
    }
  }

  Color getPitchNumberColor() {
    switch (popupDictionaryTheme) {
      case PopupDictionaryTheme.dark:
        return CupertinoColors.lightBackgroundGray;
      case PopupDictionaryTheme.light:
        return CupertinoColors.darkBackgroundGray;
      case PopupDictionaryTheme.dracula:
        return const Color(0xFFFF79c6);
    }
  }

  String getPitchStrokeColorHex() {
    switch (popupDictionaryTheme) {
      case PopupDictionaryTheme.dark:
        return colorToHex(CupertinoColors.lightBackgroundGray);
      case PopupDictionaryTheme.light:
        return colorToHex(CupertinoColors.darkBackgroundGray);
      case PopupDictionaryTheme.dracula:
        return '#f8f8f2';
    }
  }

  String getPitchGraphContrastColorHex() {
    switch (popupDictionaryTheme) {
      case PopupDictionaryTheme.dark:
        return colorToHex(CupertinoColors.darkBackgroundGray);
      case PopupDictionaryTheme.light:
        return colorToHex(CupertinoColors.lightBackgroundGray);
      case PopupDictionaryTheme.dracula:
        return '#ff79c6';
    }
  }
}
