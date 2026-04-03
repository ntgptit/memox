import 'package:drift/native.dart';
import 'package:memox/core/database/app_database.dart';

class FakeCardReviewDao extends CardReviewDao {
  factory FakeCardReviewDao() {
    final database = AppDatabase(NativeDatabase.memory());
    return FakeCardReviewDao._(database);
  }

  FakeCardReviewDao._(this._database) : super(_database);

  final AppDatabase _database;
  final List<CardReviewsTableCompanion> insertedReviews =
      <CardReviewsTableCompanion>[];

  @override
  Future<int> insertReview(CardReviewsTableCompanion review) async {
    insertedReviews.add(review);
    return insertedReviews.length;
  }

  Future<void> dispose() => _database.close();
}
