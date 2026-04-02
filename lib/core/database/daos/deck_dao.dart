part of '../app_database.dart';

@DriftAccessor(tables: [DecksTable])
class DeckDao extends DatabaseAccessor<AppDatabase> with _$DeckDaoMixin {
  DeckDao(super.db);

  Stream<List<DecksTableData>> watchAll() {
    return (select(decksTable)..orderBy([
          (DecksTable tbl) => OrderingTerm.asc(tbl.sortOrder),
          (DecksTable tbl) => OrderingTerm.asc(tbl.createdAt),
        ]))
        .watch();
  }

  Stream<List<DecksTableData>> watchByFolder(int folderId) {
    return (select(decksTable)
          ..where((DecksTable tbl) => tbl.folderId.equals(folderId))
          ..orderBy([
            (DecksTable tbl) => OrderingTerm.asc(tbl.sortOrder),
            (DecksTable tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .watch();
  }

  Future<List<DecksTableData>> getAll() {
    return (select(decksTable)..orderBy([
          (DecksTable tbl) => OrderingTerm.asc(tbl.sortOrder),
          (DecksTable tbl) => OrderingTerm.asc(tbl.createdAt),
        ]))
        .get();
  }

  Future<DecksTableData?> getById(int id) {
    return (select(
      decksTable,
    )..where((DecksTable tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertDeck(DecksTableCompanion deck) {
    return into(decksTable).insert(deck, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateDeck(DecksTableCompanion deck) {
    return update(decksTable).replace(deck);
  }

  Future<int> deleteById(int id) {
    return (delete(
      decksTable,
    )..where((DecksTable tbl) => tbl.id.equals(id))).go();
  }

  Future<int> deleteAll() => delete(decksTable).go();
}
