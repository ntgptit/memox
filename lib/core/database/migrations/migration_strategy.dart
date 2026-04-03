import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';

MigrationStrategy buildMigrationStrategy(GeneratedDatabase db) => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2 && db is AppDatabase) {
        await m.addColumn(db.cardsTable, db.cardsTable.tags);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
