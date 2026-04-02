import 'package:drift/drift.dart';

MigrationStrategy buildMigrationStrategy(GeneratedDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {},
    beforeOpen: (OpeningDetails details) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
