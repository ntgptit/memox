part of '../app_database.dart';

@DriftAccessor(tables: [FoldersTable, DecksTable, CardsTable])
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  Stream<List<FoldersTableData>> watchRootFolders() {
    return (select(foldersTable)
          ..where((FoldersTable tbl) => tbl.parentId.isNull())
          ..orderBy([
            (FoldersTable tbl) => OrderingTerm.asc(tbl.sortOrder),
            (FoldersTable tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .watch();
  }

  Stream<List<FoldersTableData>> watchByParent(int parentId) {
    return (select(foldersTable)
          ..where((FoldersTable tbl) => tbl.parentId.equals(parentId))
          ..orderBy([
            (FoldersTable tbl) => OrderingTerm.asc(tbl.sortOrder),
            (FoldersTable tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .watch();
  }

  Future<List<FoldersTableData>> getAll() {
    return (select(foldersTable)..orderBy([
          (FoldersTable tbl) => OrderingTerm.asc(tbl.sortOrder),
          (FoldersTable tbl) => OrderingTerm.asc(tbl.createdAt),
        ]))
        .get();
  }

  Future<FoldersTableData?> getById(int id) {
    return (select(
      foldersTable,
    )..where((FoldersTable tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertFolder(FoldersTableCompanion folder) {
    return into(foldersTable).insert(folder, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateFolder(FoldersTableCompanion folder) {
    return update(foldersTable).replace(folder);
  }

  Future<int> deleteById(int id) {
    return (delete(
      foldersTable,
    )..where((FoldersTable tbl) => tbl.id.equals(id))).go();
  }

  Future<int> deleteAll() => delete(foldersTable).go();

  Future<bool> hasSubfolders(int folderId) async {
    final countExpression = foldersTable.id.count();
    final count =
        await (selectOnly(foldersTable)
              ..where(foldersTable.parentId.equals(folderId))
              ..addColumns([countExpression]))
            .map((TypedResult row) => row.read(countExpression) ?? 0)
            .getSingle();
    return count > 0;
  }

  Future<bool> hasDecks(int folderId) async {
    final countExpression = decksTable.id.count();
    final count =
        await (selectOnly(decksTable)
              ..where(decksTable.folderId.equals(folderId))
              ..addColumns([countExpression]))
            .map((TypedResult row) => row.read(countExpression) ?? 0)
            .getSingle();
    return count > 0;
  }

  Future<int> getRecursiveCardCount(int folderId) async {
    final result = await customSelect(
      [
        'WITH RECURSIVE sub AS (',
        'SELECT id FROM folders_table WHERE id = ?1',
        'UNION ALL',
        'SELECT f.id FROM folders_table f',
        'JOIN sub s ON f.parent_id = s.id',
        ')',
        'SELECT COUNT(*) AS cnt FROM cards_table',
        'WHERE deck_id IN (',
        'SELECT id FROM decks_table WHERE folder_id IN (SELECT id FROM sub)',
        ')',
      ].join(' '),
      variables: [Variable<int>(folderId)],
      readsFrom: {foldersTable, decksTable, cardsTable},
    ).getSingle();
    return result.read<int>('cnt');
  }
}
