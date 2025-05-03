import 'dart:io';

import 'package:flutter/cupertino.dart';

bool isDarkMode() {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
}

Duration getDialogAnimationTime() {
  if (Platform.isAndroid) {
    return Duration(milliseconds: 0);
  } else {
    return Duration(milliseconds: 200);
  }
}
