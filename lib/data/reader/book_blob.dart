import 'dart:convert';
import 'dart:typed_data';

class BookBlob {
  String key;
  String? base64Data;

  BookBlob({required this.key, this.base64Data});

  factory BookBlob.fromMap(Map<String, Object?> map) => BookBlob(
      key: map['key'] as String, base64Data: parseBlobDataFromMap(map));

  static String parseBlobDataFromMap(Map<String, Object?> map) {
    if (map.containsKey("base64Data") && map["base64Data"] is String) {
      return map["base64Data"] as String;
    } else if (map.containsKey("prefix") && map.containsKey("data")) {
      return '${map['prefix'] as String? ?? ""},${base64Encode(map['data'] as List<int>)}';
    }
    return "";
  }

  Uint8List? get data =>
      base64Data != null ? base64Decode(base64Data!.split(',').last) : null;

  String? get prefix => base64Data?.split(',').first;
}
