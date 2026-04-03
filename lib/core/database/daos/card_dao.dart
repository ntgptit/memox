part of '../app_database.dart';

@DriftAccessor(tables: [CardsTable])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  Stream<List<CardsTableData>> watchAll() =>
      (select(cardsTable)..orderBy([
            (CardsTable tbl) => OrderingTerm.desc(tbl.updatedAt),
            (CardsTable tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
          .watch();

  Stream<List<CardsTableData>> watchByDeck(int deckId) =>
      (select(cardsTable)
            ..where((CardsTable tbl) => tbl.deckId.equals(deckId))
            ..orderBy([
              (CardsTable tbl) => OrderingTerm.desc(tbl.updatedAt),
              (CardsTable tbl) => OrderingTerm.desc(tbl.createdAt),
            ]))
          .watch();

  Future<List<CardsTableData>> getAll() =>
      (select(cardsTable)..orderBy([
            (CardsTable tbl) => OrderingTerm.desc(tbl.updatedAt),
            (CardsTable tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
          .get();

  Future<List<CardsTableData>> getByDeck(int deckId) =>
      (select(cardsTable)
            ..where((CardsTable tbl) => tbl.deckId.equals(deckId))
            ..orderBy([
              (CardsTable tbl) => OrderingTerm.desc(tbl.updatedAt),
              (CardsTable tbl) => OrderingTerm.desc(tbl.createdAt),
            ]))
          .get();

  Future<CardsTableData?> getById(int id) => (select(
    cardsTable,
  )..where((CardsTable tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertCard(CardsTableCompanion card) =>
      into(cardsTable).insert(card, mode: InsertMode.insertOrReplace);

  Future<bool> updateCard(CardsTableCompanion card) =>
      update(cardsTable).replace(card);

  Future<int> deleteById(int id) =>
      (delete(cardsTable)..where((CardsTable tbl) => tbl.id.equals(id))).go();

  Future<int> deleteByDeckIds(List<int> deckIds) {
    if (deckIds.isEmpty) {
      return Future<int>.value(0);
    }

    return (delete(
      cardsTable,
    )..where((CardsTable tbl) => tbl.deckId.isIn(deckIds))).go();
  }

  Future<int> deleteAll() => delete(cardsTable).go();

  Future<List<CardsTableData>> getDueCards({int? deckId, int? limit}) {
    final now = DateTime.now();
    final query = select(cardsTable)
      ..where((CardsTable tbl) {
        final duePredicate =
            tbl.nextReviewDate.isSmallerOrEqualValue(now) |
            tbl.status.equals(DbConstants.defaultCardStatusIndex);
        if (deckId == null) {
          return duePredicate;
        }
        return tbl.deckId.equals(deckId) & duePredicate;
      })
      ..orderBy([
        (CardsTable tbl) => OrderingTerm.asc(tbl.nextReviewDate),
        (CardsTable tbl) => OrderingTerm.asc(tbl.createdAt),
      ]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.get();
  }

  Future<({int total, int known, int learning, int newCards})>
  getMasteryBreakdown(int deckId) async {
    final rows = await (select(
      cardsTable,
    )..where((CardsTable tbl) => tbl.deckId.equals(deckId))).get();
    final known = rows
        .where((CardsTableData row) => row.status == CardStatus.mastered)
        .length;
    final learning = rows
        .where(
          (CardsTableData row) =>
              row.status == CardStatus.learning ||
              row.status == CardStatus.reviewing,
        )
        .length;
    final newCards = rows
        .where((CardsTableData row) => row.status == CardStatus.newCard)
        .length;
    return (
      total: rows.length,
      known: known,
      learning: learning,
      newCards: newCards,
    );
  }

  Future<void> insertBatch(List<CardsTableCompanion> cards) => batch(
    (Batch batch) =>
        batch.insertAll(cardsTable, cards, mode: InsertMode.insertOrReplace),
  );

  Future<List<int>> getIdsByDeckIds(List<int> deckIds) async {
    if (deckIds.isEmpty) {
      return <int>[];
    }

    final rows =
        await (selectOnly(cardsTable)
              ..addColumns([cardsTable.id])
              ..where(cardsTable.deckId.isIn(deckIds)))
            .get();
    return rows
        .map((TypedResult row) => row.read<int>(cardsTable.id)!)
        .toList();
  }
}
