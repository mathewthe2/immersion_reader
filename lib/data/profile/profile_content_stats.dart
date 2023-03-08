import 'package:immersion_reader/data/profile/profile_content.dart';

class ProfileContentStats {
  ProfileContent profileContent;
  int totalSeconds;
  static String unknownValue = '???';

  ProfileContentStats(
      {required this.profileContent, required this.totalSeconds});

  factory ProfileContentStats.fromMap(Map<String, Object?> map) =>
      ProfileContentStats(
          profileContent: ProfileContent.fromMap(map),
          totalSeconds: map['totalSeconds'] as int);

  static String _getValue(dynamic value) {
    return value == null ? unknownValue : value.toString();
  }

   String charactersRead() {
    return _getValue(profileContent.currentPosition);
  }

  String charactersReadPerSecond() {
    if (profileContent.currentPosition == null) {
      return unknownValue;
    } else {
      return (profileContent.currentPosition! / totalSeconds)
          .toStringAsFixed(2);
    }
  }

  String charactersReadOverTotal() {
    return '${_getValue(profileContent.currentPosition)} / ${_getValue(profileContent.contentLength)}';
  }

  double? getReadPercentage() {
    if (profileContent.currentPosition == null || profileContent.contentLength == null) {
      return null;
    }
    return profileContent.currentPosition! / profileContent.contentLength! * 100; 
  }
}
