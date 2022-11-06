import 'package:flutter/cupertino.dart';

bool isDarkMode() {
  return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
}
