const String vocablaryListStorageSQLString = '''
  CREATE TABLE Vocabulary (id TEXT PRIMARY KEY, folderId INTEGER, expression TEXT, reading TEXT, tags TEXT, glossary TEXT, pitch TEXT, pitch_svg TEXT, sentence TEXT)
  CREATE TABLE Folder (id TEXT PRIMARY KEY, name TEXT)
  CREATE INDEX index_Vocabulary_folder ON Vocabulary(folderId)
  INSERT INTO Folder (id, name) VALUES(1, 'Favorites')''';

const List<String> vocablaryListStorageMigrations = [];