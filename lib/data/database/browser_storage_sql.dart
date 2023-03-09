const String browserStorageSQLString = '''
  CREATE TABLE Bookmarks (id INTEGER PRIMARY KEY, name TEXT, url TEXT, parent INTEGER, type INTEGER)
  CREATE TABLE History (id INTEGER PRIMARY KEY, name TEXT, url TEXT, timestamp INTEGER)
  CREATE INDEX index_Bookmarks_parent ON Bookmarks(parent)''';

const List<String> browserStorageMigrations = [];