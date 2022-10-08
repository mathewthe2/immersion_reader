class DictionarySetting {
  int id;
  String title;
  bool enabled;

  DictionarySetting(
      {required this.id, required this.title, required this.enabled});

  factory DictionarySetting.fromMap(Map<String, Object?> map) =>
      DictionarySetting(
          id: map['id'] as int,
          title: map['title'] as String,
          enabled: (map['enabled'] as int?) == 1 ? true : false);
}
