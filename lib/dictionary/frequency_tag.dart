import 'dart:convert';

class FrequencyTag {
  FrequencyTag(
      {required this.dictionaryId,
      required this.frequency,
      this.dictionaryName});

  int dictionaryId;
  String frequency;
  String? dictionaryName;

  factory FrequencyTag.fromMap(Map<String, Object?> map) => FrequencyTag(
      dictionaryId: map['dictionaryId'] as int,
      dictionaryName: map['dictionaryName'] as String,
      frequency: map['frequency'] as String);

  factory FrequencyTag.fromString(String jsonString) =>
      FrequencyTag.fromMap(jsonDecode(jsonString));

  @override
  String toString() {
    return jsonEncode({
      "dictionaryId": dictionaryId,
      "dictionaryName": dictionaryName,
      "frequency": frequency
    });
  }
}
