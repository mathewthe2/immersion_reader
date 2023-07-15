import 'dart:convert';

class DarkReaderSetting {
  int brightness;
  int contrast;
  int sepia;

  DarkReaderSetting(
      {required this.brightness, required this.contrast, required this.sepia});

  factory DarkReaderSetting.fromJson(Map<String, dynamic> json) =>
      DarkReaderSetting(
          brightness: json['brightness'] as int,
          contrast: json['contrast'] as int,
          sepia: json['sepia']);

  static DarkReaderSetting defaultSetting() {
    return DarkReaderSetting(brightness: 100, contrast: 90, sepia: 10);
  }

  @override
  String toString() {
    return json.encode(
        {'brightness': brightness, 'contrast': contrast, 'sepia': sepia});
  }
}
