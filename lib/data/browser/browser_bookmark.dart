enum BrowserBookMarkType { link, folder }

Map<int, BrowserBookMarkType> browserBookMarkTypeMap = {
  1: BrowserBookMarkType.link,
  2: BrowserBookMarkType.folder
};

class BrowserBookmark {
  int id;
  String name;
  String url;
  int parent; // id of parent; 0:root
  BrowserBookMarkType type;
  
  static const int temporaryId = 0;
  static const int rootParent = 0;

  BrowserBookmark(
      {required this.id,
      required this.name,
      required this.url,
      required this.parent,
      required this.type});

  factory BrowserBookmark.fromMap(Map<String, Object?> map) => BrowserBookmark(
      id: map['id'] as int,
      name: map['name'] as String,
      url: map['url'] as String,
      parent: map['parent'] as int,
      type: browserBookMarkTypeMap[map['type']]!);

  factory BrowserBookmark.fromLink(String name, Uri url) => BrowserBookmark(
      id: temporaryId,
      name: name,
      url: url.toString(),
      parent: rootParent,
      type: BrowserBookMarkType.link);

  bool isFolder() {
    return type == BrowserBookMarkType.folder;
  }
  
  int getTypeValue() {
    return browserBookMarkTypeMap.keys.firstWhere((k) => browserBookMarkTypeMap[k] == type);
  }
}
