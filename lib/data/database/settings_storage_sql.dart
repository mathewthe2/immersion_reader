const String settingsStorageSQLString = '''
  CREATE TABLE Dictionary (id INTEGER PRIMARY KEY, title TEXT, enabled INTEGER)
  CREATE TABLE Kanji(id INTEGER PRIMARY KEY, dictionaryId INTEGER, character TEXT, kunyomi TEXT, onyomi TEXT, FOREIGN KEY(dictionaryId) REFERENCES Dictionary(id))
  CREATE TABLE KanjiGloss(glossary TEXT, kanjiId INTEGER, dictionaryId INTEGER, FOREIGN KEY(dictionaryId) REFERENCES Dictionary(id))
  CREATE TABLE Vocab(id INTEGER PRIMARY KEY, dictionaryId INTEGER, expression TEXT, reading TEXT, sequence INTEGER, popularity REAL, meaningTags TEXT, termTags TEXT, FOREIGN KEY(dictionaryId) REFERENCES Dictionary(id))
  CREATE TABLE VocabGloss(glossary TEXT, vocabId INTEGER, dictionaryId INTEGER, FOREIGN KEY(vocabId) REFERENCES Vocab(id), FOREIGN KEY(dictionaryId) REFERENCES Dictionary(id))
  CREATE TABLE VocabFreq(expression TEXT, reading TEXT, frequency TEXT, dictionaryId INTEGER, FOREIGN KEY(dictionaryId) REFERENCES Dictionary(id))
  CREATE TABLE VocabPitch(expression TEXT, reading TEXT, pitch TEXT, dictionaryId INTEGER, FOREIGN KEY(dictionaryId) REFERENCES Dictionary(id))
  CREATE TABLE Config(title TEXT, customValue TEXT, category TEXT)
  CREATE INDEX index_VocabGloss_vocabId ON VocabGloss(vocabId)
  CREATE INDEX index_Vocab_expression ON Vocab(expression)
  CREATE INDEX index_Vocab_reading ON Vocab(reading)
  CREATE INDEX index_VocabFreq_expression ON VocabFreq(expression)
  CREATE INDEX index_VocabFreq_reading ON VocabFreq(reading)
  CREATE INDEX index_VocabPitch_expression ON VocabPitch(expression ASC)
  CREATE INDEX index_VocabPitch_reading ON VocabPitch(reading ASC)''';

const List<String> settingsStorageMigrations = [
  'CREATE TABLE DictionaryHistory (id INTEGER PRIMARY KEY, date TEXT, query TEXT UNIQUE, vocabId INTEGER, kanjiId INTEGER, dictionaryId INTEGER, vocabJson TEXT, kanjiJson TEXT)', // add dictionary search history
  'CREATE INDEX index_DictionaryHistory_date ON DictionaryHistory(date)', // add index for dictionary history for ordering
  'CREATE TABLE Books (id INTEGER PRIMARY KEY, title TEXT, lastReadTime TEXT, authorId TEXT, elementHtml TEXT, styleSheet TEXT, coverImagePrefix TEXT, coverImageData BLOB, hasThumb INTEGER)',
  'CREATE TABLE BookSections (id INTEGER PRIMARY KEY, bookId INTEGER, reference TEXT, charactersWeight INTEGER, label TEXT, startCharacter INTEGER, characters INTEGER, parentChapter TEXT, FOREIGN KEY(bookId) REFERENCES Books(id))',
  'CREATE INDEX index_BookSections_bookId ON BookSections(bookId)',
  'CREATE TABLE BookBlobs (id INTEGER PRIMARY KEY, bookId INTEGER, key TEXT, prefix TEXT, data BLOB, FOREIGN KEY(bookId) REFERENCES Books(id))',
  'CREATE INDEX index_BookBlobs_bookId ON BookBlobs(bookId)',
  'CREATE TABLE BookBookmarks (id INTEGER PRIMARY KEY, bookId INTEGER UNIQUE, exploredCharCount INTEGER, progress REAL, FOREIGN KEY(bookId) REFERENCES Books(id))',
  'CREATE INDEX index_BookBookmarks_bookId ON BookBookmarks(bookId)',
  'CREATE INDEX index_books_title ON Books (title)', // sort books basd on title
  'CREATE INDEX index_books_lastReadTime ON Books (lastReadTime)',
  "ALTER TABLE Dictionary ADD version TEXT DEFAULT '1.0.0'",
  'CREATE INDEX index_Vocab_dictionaryId ON Vocab(dictionaryId)',
  'CREATE INDEX index_VocabFreq_dictionaryId ON VocabFreq(dictionaryId)',
  'ALTER TABLE Books ADD playBackPositionInMs INTEGER', // audio book
  'ALTER TABLE Books ADD matchedSubtitles INTEGER', // audio book
  "ALTER TABLE Books ADD version INTEGER DEFAULT 1"
];
