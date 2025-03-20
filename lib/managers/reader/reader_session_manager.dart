import 'package:immersion_reader/data/profile/profile_content.dart';
import 'package:immersion_reader/managers/profile/profile_manager.dart';

class ReaderSessionManager {
  late String contentType;
  ProfileContent? currentProfileContent;

  static final ReaderSessionManager _singleton =
      ReaderSessionManager._internal();
  ReaderSessionManager._internal();

  factory ReaderSessionManager.createSession(String contentType) {
    _singleton.contentType = contentType;
    return _singleton;
  }

  factory ReaderSessionManager() => _singleton;

  void start(
      {required String key, required String title, int? contentLength}) async {
    bool isSameContent = currentProfileContent != null &&
        currentProfileContent!.key == key &&
        currentProfileContent!.title == title;
    if (isSameContent) {
      return;
    }
    currentProfileContent ??= ProfileContent(
        key: key,
        title: title,
        type: contentType,
        contentLength: contentLength,
        lastOpened: DateTime.now());
    int? contentId =
        await ProfileManager().startSession(currentProfileContent!);
    if (contentId != null) {
      currentProfileContent!.id = contentId;
    }
  }

  void stop() {
    ProfileManager().destroySession();
    currentProfileContent = null;
  }

  void updateProgressOfCurrentContent(int currentPosition) {
    if (currentProfileContent != null) {
      ProfileManager().updateProfileContentPosition(
          currentProfileContent!, currentPosition);
    }
  }
}
