import 'package:immersion_reader/data/profile/profile_content.dart';
import 'package:immersion_reader/providers/profile_provider.dart';

class ReaderSessionManager {
  late ProfileProvider profileProvider;
  late String contentType;
  ProfileContent? currentProfileContent;

  static final ReaderSessionManager _singleton = ReaderSessionManager._internal();
  ReaderSessionManager._internal();

  factory ReaderSessionManager.createSession(ProfileProvider profileProvider, String contentType) {
    _singleton.profileProvider = profileProvider;
    _singleton.contentType = contentType;
    return _singleton;
  }
  
  factory ReaderSessionManager() => _singleton;

  void start({required String key, required String title, int? contentLength}) async {
    bool isSameContent = currentProfileContent != null &&
        currentProfileContent!.key == key &&
        currentProfileContent!.title == title;
    if (isSameContent) {
      return;
    }
    currentProfileContent ??= ProfileContent(
        key: key, title: title, type: contentType, contentLength: contentLength, lastOpened: DateTime.now());
    int? contentId = await profileProvider.startSession(currentProfileContent!);
    if (contentId != null) {
      currentProfileContent!.id = contentId;
    }
  }

  void stop() {
    profileProvider.destroySession();
    currentProfileContent = null;
  }

  void updateProgressOfCurrentContent(int currentPosition) {
    profileProvider.updateProfileContentPosition(currentProfileContent!, currentPosition);
  }
}
