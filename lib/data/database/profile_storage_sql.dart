const String profileStorageSQLString = '''
  CREATE TABLE Content (id INTEGER PRIMARY KEY, key TEXT, title TEXT, type TEXT, lastOpened TEXT)
  CREATE TABLE Sessions (id INTEGER PRIMARY KEY, startTime TEXT, durationSeconds INTEGER, contentId INTEGER, goalId INTEGER, FOREIGN KEY(contentId) REFERENCES Content(id), FOREIGN KEY(goalId) REFERENCES Goals(id))
  CREATE TABLE Goals (id INTEGER PRIMARY KEY, date TEXT, goalSeconds INTEGER)
  CREATE INDEX index_Sessions_start ON Sessions(startTime)
  CREATE INDEX index_Content_key ON Content(key)
  CREATE INDEX index_Content_title ON Content(key)
  CREATE INDEX index_Content_lastOpened ON Content(lastOpened)''';