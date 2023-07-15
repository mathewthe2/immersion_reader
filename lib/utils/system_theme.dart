import 'package:flutter/cupertino.dart';

bool isDarkMode() {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
}
