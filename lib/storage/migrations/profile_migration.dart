import 'package:sqflite/sqflite.dart';

Future<void> migrate(Database database, currentDBVersion, int databaseVersion) async {
  switch (databaseVersion) {
    case 1:
      await migrateFromVersionOne(database);
      break;
  }
  await database.setVersion(currentDBVersion);
}

Future<void> migrateFromVersionOne(Database database) async {
  Batch batch = database.batch();
  batch.rawQuery('ALTER TABLE Content ADD COLUMN contentLength INTEGER');
  batch.rawQuery('ALTER TABLE Content ADD COLUMN completedDate TEXT');
  batch.rawQuery('ALTER TABLE Sessions ADD COLUMN progressCount INTEGER');
  await batch.commit();
}