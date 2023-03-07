import 'package:immersion_reader/data/reader/book.dart';

class ProfileContent {
  int id;
  String key; // identifier used by ttu, otherwise same as id
  String title;
  String type; // type of content - book / news / webpage
  int? contentLength; // number of characters for books
  int? currentPosition; // number of characterse read for books
  int vocabularyMined; // number of vocabulary mined; default 0
  DateTime lastOpened;

  ProfileContent(
      {this.id = 0,
      required this.key,
      required this.title,
      required this.type,
      this.contentLength,
      this.currentPosition,
      this.vocabularyMined = 0,
      required this.lastOpened});

  factory ProfileContent.fromMap(Map<String, Object?> map) => ProfileContent(
      id: map['id'] as int,
      key: map['key'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      contentLength: map['contentLength'] as int?,
      currentPosition: map['currentPosition'] as int?,
      vocabularyMined: map['vocabularyMined'] as int,
      lastOpened: DateTime.parse(map['lastOpened'] as String));

   Book get book  =>  Book(title: title);
}
