enum BrowserBookMarkType {
  bookmark,
  folder  
}

Map<int, BrowserBookMarkType> browserBookMarkTypeMap = {
  1: BrowserBookMarkType.bookmark,
  2: BrowserBookMarkType.folder
};

class BrowserBookmark {
  int id;
  String name;
  String url;
  int parent; // id of parent; 0:root
  BrowserBookMarkType type;

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
}