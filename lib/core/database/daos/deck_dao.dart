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

  Future<List<DecksTableData>> getByFolder(int folderId) {
    return (select(decksTable)
          ..where((DecksTable tbl) => tbl.folderId.equals(folderId))
          ..orderBy([
            (DecksTable tbl) => OrderingTerm.asc(tbl.sortOrder),
            (DecksTable tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .get();
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

  Future<int> deleteByFolderIds(List<int> folderIds) {
    if (folderIds.isEmpty) {
      return Future<int>.value(0);
    }

    return (delete(
      decksTable,
    )..where((DecksTable tbl) => tbl.folderId.isIn(folderIds))).go();
  }

  Future<int> deleteAll() => delete(decksTable).go();

  Future<List<int>> getIdsByFolderIds(List<int> folderIds) async {
    if (folderIds.isEmpty) {
      return <int>[];
    }

    final rows =
        await (selectOnly(decksTable)
              ..addColumns([decksTable.id])
              ..where(decksTable.folderId.isIn(folderIds)))
            .get();
    return rows
        .map((TypedResult row) => row.read<int>(decksTable.id)!)
        .toList();
  }

  Future<int> getNextSortOrder(int folderId) async {
    final maxExpression = decksTable.sortOrder.max();
    final currentMax =
        await (selectOnly(decksTable)
              ..addColumns([maxExpression])
              ..where(decksTable.folderId.equals(folderId)))
            .map((TypedResult row) => row.read(maxExpression))
            .getSingle();
    return (currentMax ?? -1) + 1;
  }

  Future<void> reorder(int folderId, List<int> deckIds) {
    return transaction(() async {
      for (var index = 0; index < deckIds.length; index++) {
        final deckId = deckIds[index];
        await (update(
          decksTable,
        )..where((DecksTable tbl) => tbl.id.equals(deckId))).write(
          DecksTableCompanion(
            folderId: Value<int>(folderId),
            sortOrder: Value<int>(index),
            updatedAt: Value<DateTime>(DateTime.now()),
          ),
        );
      }
    });
  }
}
