part of '../app_database.dart';

@DriftAccessor(tables: [CardReviewsTable])
class CardReviewDao extends DatabaseAccessor<AppDatabase>
    with _$CardReviewDaoMixin {
  CardReviewDao(super.db);

  Future<List<CardReviewsTableData>> getAll() =>
      (select(cardReviewsTable)..orderBy([
            (CardReviewsTable tbl) => OrderingTerm.desc(tbl.reviewedAt),
          ]))
          .get();

  Future<int> insertReview(CardReviewsTableCompanion review) =>
      into(cardReviewsTable).insert(review, mode: InsertMode.insertOrReplace);

  Future<int> countByCardIds(List<int> cardIds) async {
    if (cardIds.isEmpty) {
      return 0;
    }

    final countExpression = cardReviewsTable.id.count();
    return (selectOnly(cardReviewsTable)
          ..addColumns([countExpression])
          ..where(cardReviewsTable.cardId.isIn(cardIds)))
        .map((TypedResult row) => row.read(countExpression) ?? 0)
        .getSingle();
  }

  Future<int> deleteByCardIds(List<int> cardIds) {
    if (cardIds.isEmpty) {
      return Future<int>.value(0);
    }

    return (delete(
      cardReviewsTable,
    )..where((CardReviewsTable tbl) => tbl.cardId.isIn(cardIds))).go();
  }

  Future<int> deleteAll() => delete(cardReviewsTable).go();

  Stream<int> watchTotalReviews() {
    final countExpression = cardReviewsTable.id.count();
    return (selectOnly(cardReviewsTable)..addColumns([countExpression]))
        .map((TypedResult row) => row.read(countExpression) ?? 0)
        .watchSingle();
  }
}
