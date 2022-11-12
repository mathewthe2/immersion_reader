import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:flutter/cupertino.dart';

enum DictionaryColor {
  backgroundColor,
  primaryTextColor,
  secondaryTextColor,
  primaryActionColor,
  segmentColor,
  segmentThumbColor,
  pitchNumberColor,
  pitchStrokeColor, // hex
  pitchGraphContrastColor // hex
}

// dracula color palette
// https://draculatheme.com/contribute

Map<DictionaryColor, Map<PopupDictionaryTheme, Color>> dictionaryColorDataMap =
    {
  DictionaryColor.backgroundColor: {
    ...{
      PopupDictionaryTheme.dark: CupertinoColors.darkBackgroundGray,
      PopupDictionaryTheme.dracula: const Color(0xFF282a36),
      PopupDictionaryTheme.light: CupertinoColors.white,
      PopupDictionaryTheme.purple: const Color(0xFF9B99E9),
    }
  },
  DictionaryColor.primaryTextColor: {
    ...{
      PopupDictionaryTheme.dark: CupertinoColors.white,
      PopupDictionaryTheme.dracula: const Color(0xFFF8F8F2),
      PopupDictionaryTheme.light: CupertinoColors.darkBackgroundGray,
      PopupDictionaryTheme.purple: CupertinoColors.white
    }
  },
  DictionaryColor.secondaryTextColor: {
    ...{
      PopupDictionaryTheme.dark: CupertinoColors.lightBackgroundGray,
      PopupDictionaryTheme.dracula: CupertinoColors.lightBackgroundGray,
      PopupDictionaryTheme.light: CupertinoColors.inactiveGray,
      PopupDictionaryTheme.purple: CupertinoColors.lightBackgroundGray
    }
  },
  DictionaryColor.primaryActionColor: {
    ...{
      PopupDictionaryTheme.dark: CupertinoColors.activeBlue,
      PopupDictionaryTheme.dracula: const Color(0xFFF8F8F2),
      PopupDictionaryTheme.light: CupertinoColors.activeBlue,
      PopupDictionaryTheme.purple: CupertinoColors.white
    }
  },
  DictionaryColor.segmentColor: {
    ...{
      PopupDictionaryTheme.dark: CupertinoColors.white,
      PopupDictionaryTheme.dracula: const Color(0xFFF8F8F2),
      PopupDictionaryTheme.light: CupertinoColors.darkBackgroundGray,
      PopupDictionaryTheme.purple: CupertinoColors.white,
    }
  },
  DictionaryColor.segmentThumbColor: {
    ...{
      PopupDictionaryTheme.dark: const Color(0xFF636366),
      PopupDictionaryTheme.dracula: const Color(0xFF44475A),
      PopupDictionaryTheme.light: CupertinoColors.white,
      PopupDictionaryTheme.purple: const Color(0xFF6566B1),
    }
  },
  DictionaryColor.pitchNumberColor: {
    ...{
      PopupDictionaryTheme.dark: CupertinoColors.lightBackgroundGray,
      PopupDictionaryTheme.dracula: const Color(0xFFFF79c6),
      PopupDictionaryTheme.light: CupertinoColors.darkBackgroundGray,
      PopupDictionaryTheme.purple: CupertinoColors.darkBackgroundGray
    }
  }
};

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16)}';
}

Map<DictionaryColor, Map<PopupDictionaryTheme, String>>
    dictionaryHexColorDataMap = {
  DictionaryColor.pitchStrokeColor: {
    ...{
      PopupDictionaryTheme.dark:
          colorToHex(CupertinoColors.lightBackgroundGray),
      PopupDictionaryTheme.dracula: '#f8f8f2',
      PopupDictionaryTheme.light:
          colorToHex(CupertinoColors.darkBackgroundGray),
      PopupDictionaryTheme.purple:
          colorToHex(CupertinoColors.lightBackgroundGray)
    }
  },
  DictionaryColor.pitchGraphContrastColor: {
    ...{
      PopupDictionaryTheme.dark: colorToHex(CupertinoColors.darkBackgroundGray),
      PopupDictionaryTheme.dracula: '#ff79c6',
      PopupDictionaryTheme.light:
          colorToHex(CupertinoColors.lightBackgroundGray),
      PopupDictionaryTheme.purple:
          colorToHex(CupertinoColors.darkBackgroundGray),
    }
  }
};

class PopupDictionaryThemeData {
  PopupDictionaryTheme popupDictionaryTheme;

  PopupDictionaryThemeData({required this.popupDictionaryTheme});

  Color getColor(DictionaryColor dictionaryColor) {
    return dictionaryColorDataMap[dictionaryColor]![popupDictionaryTheme]!;
  }

  String getPitchStrokeColorHex() {
    return dictionaryHexColorDataMap[DictionaryColor.pitchStrokeColor]![
        popupDictionaryTheme]!;
  }

  String getPitchGraphContrastColorHex() {
    return dictionaryHexColorDataMap[DictionaryColor.pitchGraphContrastColor]![
        popupDictionaryTheme]!;
  }
}
