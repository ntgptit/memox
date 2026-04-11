import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:memox/core/database/app_database.dart';

class FakeCardReviewDao extends CardReviewDao {
  factory FakeCardReviewDao() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final database = AppDatabase(NativeDatabase.memory());
    return FakeCardReviewDao._(database);
  }

  FakeCardReviewDao._(this._database) : super(_database);

  final AppDatabase _database;
  final List<CardReviewsTableCompanion> insertedReviews =
      <CardReviewsTableCompanion>[];
  final List<int> deletedReviewIds = <int>[];

  @override
  Future<int> insertReview(CardReviewsTableCompanion review) async {
    insertedReviews.add(review);
    return insertedReviews.length;
  }

  @override
  Future<int> deleteById(int reviewId) async {
    deletedReviewIds.add(reviewId);
    return 1;
  }

  Future<void> dispose() => _database.close();
}
