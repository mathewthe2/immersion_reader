class SearchHistoryItem {
  int id;
  String query;

  SearchHistoryItem({required this.id, required this.query});

  factory SearchHistoryItem.fromMap(Map<String, Object?> map) =>
      SearchHistoryItem(id: map['id'] as int, query: map['query'] as String);
}
