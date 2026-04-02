part of '../app_database.dart';

@DriftAccessor(tables: [CardReviewsTable])
class CardReviewDao extends DatabaseAccessor<AppDatabase>
    with _$CardReviewDaoMixin {
  CardReviewDao(super.db);

  Future<List<CardReviewsTableData>> getAll() {
    return (select(cardReviewsTable)..orderBy([
          (CardReviewsTable tbl) => OrderingTerm.desc(tbl.reviewedAt),
        ]))
        .get();
  }

  Future<int> insertReview(CardReviewsTableCompanion review) {
    return into(
      cardReviewsTable,
    ).insert(review, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteAll() => delete(cardReviewsTable).go();

  Stream<int> watchTotalReviews() {
    final countExpression = cardReviewsTable.id.count();
    return (selectOnly(cardReviewsTable)..addColumns([countExpression]))
        .map((TypedResult row) => row.read(countExpression) ?? 0)
        .watchSingle();
  }
}
