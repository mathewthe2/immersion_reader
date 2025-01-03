import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:immersion_reader/managers/profile/profile_manager.dart';

class NavigationManager {
  ValueNotifier<bool> leaveReaderPageNotifier = ValueNotifier(false);
  ValueNotifier<bool> vocabularyListNotifier = ValueNotifier(false);

  static final NavigationManager _singleton = NavigationManager._internal();
  NavigationManager._internal();

  factory NavigationManager() => _singleton;

  Future<void> handleReaderSession(
      {required bool isTerminateSession,
      required bool isStartSession,
      required bool isSamePage}) async {
    if (isTerminateSession) {
      ProfileManager().endSession();
      WakelockPlus.disable();
      if (!isSamePage) {
        leaveReaderPageNotifier.value = true;
      }
    } else if (isStartSession) {
      ProfileManager().restartSession();
      bool isKeepScreenOn = await SettingsManager().getIsKeepScreenOn();
      if (isKeepScreenOn) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
      leaveReaderPageNotifier.value = false;
    }
  }

  void notifyVocabularyListPage() {
    vocabularyListNotifier.value = !vocabularyListNotifier.value;
  }
}
