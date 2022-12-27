class ProfileContent {
  int id;
  String key; // identifier used by ttu, otherwise same as id
  String title;
  String type; // type of content - book / news / webpage
  DateTime lastOpened;

  ProfileContent(
      {this.id = 0,
      required this.key,
      required this.title,
      required this.type,
      required this.lastOpened});

  factory ProfileContent.fromMap(Map<String, Object?> map) => ProfileContent(
      id: map['id'] as int,
      key: map['key'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      lastOpened: DateTime.parse(map['lastOpened'] as String));
}
