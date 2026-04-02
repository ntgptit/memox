import 'package:drift/drift.dart';
import 'package:memox/core/database/tables/cards_table.dart';
import 'package:memox/core/database/tables/study_sessions_table.dart';
import 'package:memox/core/design/study_mode.dart';

class CardReviewsTable extends Table {
  @override
  String get tableName => 'card_reviews_table';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get cardId => integer().references(CardsTable, #id)();

  IntColumn get sessionId => integer().references(StudySessionsTable, #id)();

  IntColumn get mode => intEnum<StudyMode>()();

  IntColumn get rating => integer().nullable()();

  IntColumn get selfRating => integer().nullable()();

  BoolColumn get isCorrect => boolean()();

  TextColumn get userAnswer => text().withDefault(const Constant(''))();

  IntColumn get responseTimeMs => integer().withDefault(const Constant(0))();

  DateTimeColumn get reviewedAt => dateTime()();
}
