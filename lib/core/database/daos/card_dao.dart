part of '../app_database.dart';

@DriftAccessor(tables: [CardsTable])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  Stream<List<CardsTableData>> watchAll() {
    return (select(cardsTable)..orderBy([
          (CardsTable tbl) => OrderingTerm.desc(tbl.updatedAt),
          (CardsTable tbl) => OrderingTerm.desc(tbl.createdAt),
        ]))
        .watch();
  }

  Future<List<CardsTableData>> getAll() {
    return (select(cardsTable)..orderBy([
          (CardsTable tbl) => OrderingTerm.desc(tbl.updatedAt),
          (CardsTable tbl) => OrderingTerm.desc(tbl.createdAt),
        ]))
        .get();
  }

  Future<CardsTableData?> getById(int id) {
    return (select(
      cardsTable,
    )..where((CardsTable tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertCard(CardsTableCompanion card) {
    return into(cardsTable).insert(card, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateCard(CardsTableCompanion card) {
    return update(cardsTable).replace(card);
  }

  Future<int> deleteById(int id) {
    return (delete(
      cardsTable,
    )..where((CardsTable tbl) => tbl.id.equals(id))).go();
  }

  Future<int> deleteAll() => delete(cardsTable).go();

  Future<List<CardsTableData>> getDueCards({
    int? deckId,
    int limit = DbConstants.defaultGoalCount,
  }) {
    final now = DateTime.now();
    return (select(cardsTable)
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
          ])
          ..limit(limit))
        .get();
  }

  Future<({int total, int known, int learning, int newCards})>
  getMasteryBreakdown(int deckId) async {
    final rows = await (select(
      cardsTable,
    )..where((CardsTable tbl) => tbl.deckId.equals(deckId))).get();
    final known = rows.where((CardsTableData row) {
      return row.status == CardStatus.mastered;
    }).length;
    final learning = rows.where((CardsTableData row) {
      return row.status == CardStatus.learning ||
          row.status == CardStatus.reviewing;
    }).length;
    final newCards = rows.where((CardsTableData row) {
      return row.status == CardStatus.newCard;
    }).length;
    return (
      total: rows.length,
      known: known,
      learning: learning,
      newCards: newCards,
    );
  }

  Future<void> insertBatch(List<CardsTableCompanion> cards) {
    return batch(
      (Batch batch) =>
          batch.insertAll(cardsTable, cards, mode: InsertMode.insertOrReplace),
    );
  }
}
