part of '../app_database.dart';

@DriftAccessor(tables: [FoldersTable, DecksTable, CardsTable])
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  Stream<List<FoldersTableData>> watchAllFolders() => (select(foldersTable)..orderBy([
          (FoldersTable tbl) => OrderingTerm.asc(tbl.sortOrder),
          (FoldersTable tbl) => OrderingTerm.asc(tbl.createdAt),
        ]))
        .watch();

  Stream<List<FoldersTableData>> watchRootFolders() => (select(foldersTable)
          ..where((FoldersTable tbl) => tbl.parentId.isNull())
          ..orderBy([
            (FoldersTable tbl) => OrderingTerm.asc(tbl.sortOrder),
            (FoldersTable tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .watch();

  Stream<List<FoldersTableData>> watchByParent(int parentId) => (select(foldersTable)
          ..where((FoldersTable tbl) => tbl.parentId.equals(parentId))
          ..orderBy([
            (FoldersTable tbl) => OrderingTerm.asc(tbl.sortOrder),
            (FoldersTable tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .watch();

  Future<List<FoldersTableData>> getAll() => (select(foldersTable)..orderBy([
          (FoldersTable tbl) => OrderingTerm.asc(tbl.sortOrder),
          (FoldersTable tbl) => OrderingTerm.asc(tbl.createdAt),
        ]))
        .get();

  Future<FoldersTableData?> getById(int id) => (select(
      foldersTable,
    )..where((FoldersTable tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<FoldersTableData>> getByParent(int? parentId) {
    final query = select(foldersTable)
      ..orderBy([
        (FoldersTable tbl) => OrderingTerm.asc(tbl.sortOrder),
        (FoldersTable tbl) => OrderingTerm.asc(tbl.createdAt),
      ]);

    if (parentId == null) {
      query.where((FoldersTable tbl) => tbl.parentId.isNull());
      return query.get();
    }

    query.where((FoldersTable tbl) => tbl.parentId.equals(parentId));
    return query.get();
  }

  Future<int> insertFolder(FoldersTableCompanion folder) => into(foldersTable).insert(folder, mode: InsertMode.insertOrReplace);

  Future<bool> updateFolder(FoldersTableCompanion folder) => update(foldersTable).replace(folder);

  Future<void> updateFolderPresentation({
    required int id,
    required String name,
    required int colorValue,
  }) => (update(foldersTable)..where((FoldersTable tbl) => tbl.id.equals(id)))
      .write(
        FoldersTableCompanion(
          name: Value<String>(name),
          colorValue: Value<int>(colorValue),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );

  Future<int> deleteById(int id) => (delete(
      foldersTable,
    )..where((FoldersTable tbl) => tbl.id.equals(id))).go();

  Future<int> deleteByIds(List<int> folderIds) {
    if (folderIds.isEmpty) {
      return Future<int>.value(0);
    }

    return (delete(
      foldersTable,
    )..where((FoldersTable tbl) => tbl.id.isIn(folderIds))).go();
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

  Future<int> getNextSortOrder(int? parentId) async {
    final maxExpression = foldersTable.sortOrder.max();
    final query = selectOnly(foldersTable)..addColumns([maxExpression]);

    if (parentId == null) {
      query.where(foldersTable.parentId.isNull());
    }

    if (parentId != null) {
      query.where(foldersTable.parentId.equals(parentId));
    }

    final currentMax = await query
        .map((TypedResult row) => row.read(maxExpression))
        .getSingle();
    return (currentMax ?? -1) + 1;
  }

  Future<void> reorderByParent(int? parentId, List<int> folderIds) => transaction(() async {
      for (var index = 0; index < folderIds.length; index++) {
        final folderId = folderIds[index];
        await (update(
          foldersTable,
        )..where((FoldersTable tbl) => tbl.id.equals(folderId))).write(
          FoldersTableCompanion(
            parentId: Value<int?>(parentId),
            sortOrder: Value<int>(index),
            updatedAt: Value<DateTime>(DateTime.now()),
          ),
        );
      }
    });

  Future<List<int>> getDescendantIds(int folderId) async {
    final result = await customSelect(
      [
        'WITH RECURSIVE sub AS (',
        'SELECT id, parent_id FROM folders_table WHERE parent_id = ?1',
        'UNION ALL',
        'SELECT f.id, f.parent_id FROM folders_table f',
        'JOIN sub s ON f.parent_id = s.id',
        ')',
        'SELECT id FROM sub',
      ].join(' '),
      variables: [Variable<int>(folderId)],
      readsFrom: {foldersTable},
    ).get();
    return result.map<int>((row) => row.read<int>('id')).toList();
  }

  Future<
    ({int subfolderCount, int deckCount, int totalCards, int masteredCards})
  >
  getRecursiveStats(int folderId) async {
    final result = await customSelect(
      [
        'WITH RECURSIVE sub AS (',
        'SELECT id FROM folders_table WHERE id = ?1',
        'UNION ALL',
        'SELECT f.id FROM folders_table f',
        'JOIN sub s ON f.parent_id = s.id',
        ')',
        'SELECT',
        '(SELECT COUNT(*) FROM sub WHERE id != ?1) AS subfolder_count,',
        '(SELECT COUNT(*) FROM decks_table',
        '  WHERE folder_id IN (SELECT id FROM sub)) AS deck_count,',
        '(SELECT COUNT(*) FROM cards_table',
        '  WHERE deck_id IN (SELECT id FROM decks_table',
        '    WHERE folder_id IN (SELECT id FROM sub))) AS total_cards,',
        '(SELECT COUNT(*) FROM cards_table',
        '  WHERE status = ?2',
        '    AND deck_id IN (SELECT id FROM decks_table',
        '      WHERE folder_id IN (SELECT id FROM sub))) AS mastered_cards',
      ].join(' '),
      variables: [
        Variable<int>(folderId),
        Variable<int>(CardStatus.mastered.index),
      ],
      readsFrom: {foldersTable, decksTable, cardsTable},
    ).getSingle();
    return (
      subfolderCount: result.read<int>('subfolder_count'),
      deckCount: result.read<int>('deck_count'),
      totalCards: result.read<int>('total_cards'),
      masteredCards: result.read<int>('mastered_cards'),
    );
  }

  Future<({int subfolderCount, int deckCount, int cardCount})> getDeleteCounts(
    int folderId,
  ) async {
    final result = await customSelect(
      [
        'WITH RECURSIVE sub AS (',
        'SELECT id FROM folders_table WHERE id = ?1',
        'UNION ALL',
        'SELECT f.id FROM folders_table f',
        'JOIN sub s ON f.parent_id = s.id',
        ')',
        'SELECT',
        '(SELECT COUNT(*) FROM sub WHERE id != ?1) AS subfolder_count,',
        '(SELECT COUNT(*) FROM decks_table',
        '  WHERE folder_id IN (SELECT id FROM sub)) AS deck_count,',
        '(SELECT COUNT(*) FROM cards_table',
        '  WHERE deck_id IN (SELECT id FROM decks_table',
        '    WHERE folder_id IN (SELECT id FROM sub))) AS card_count',
      ].join(' '),
      variables: [Variable<int>(folderId)],
      readsFrom: {foldersTable, decksTable, cardsTable},
    ).getSingle();
    return (
      subfolderCount: result.read<int>('subfolder_count'),
      deckCount: result.read<int>('deck_count'),
      cardCount: result.read<int>('card_count'),
    );
  }
}
