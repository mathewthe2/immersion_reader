import 'package:immersion_reader/data/profile/profile_content.dart';
import 'package:immersion_reader/providers/profile_provider.dart';

class ReaderSessionProvider {
  late ProfileProvider profileProvider;
  late String contentType;
  ProfileContent? currentProfileContent;

  ReaderSessionProvider._create() {
    // print("_create() (private constructor)");
  }

  static ReaderSessionProvider create(
      ProfileProvider profileProvider, String contentType) {
    ReaderSessionProvider observer = ReaderSessionProvider._create();
    observer.profileProvider = profileProvider;
    observer.contentType = contentType;
    return observer;
  }

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
