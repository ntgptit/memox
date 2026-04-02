import 'package:drift/drift.dart';
import 'package:memox/core/database/db_constants.dart';
import 'package:memox/core/database/tables/decks_table.dart';
import 'package:memox/core/design/card_status.dart';

class CardsTable extends Table {
  @override
  String get tableName => 'cards_table';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get deckId => integer().references(DecksTable, #id)();

  TextColumn get front => text()();

  TextColumn get back => text()();

  TextColumn get hint => text().withDefault(const Constant(''))();

  TextColumn get example => text().withDefault(const Constant(''))();

  TextColumn get imagePath => text().withDefault(const Constant(''))();

  IntColumn get status => intEnum<CardStatus>().withDefault(
    const Constant(DbConstants.defaultCardStatusIndex),
  )();

  RealColumn get easeFactor =>
      real().withDefault(const Constant(DbConstants.defaultEaseFactor))();

  IntColumn get interval => integer().withDefault(const Constant(0))();

  IntColumn get repetitions => integer().withDefault(const Constant(0))();

  DateTimeColumn get nextReviewDate => dateTime().nullable()();

  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
