import 'package:drift/drift.dart';
import 'package:memox/core/database/db_constants.dart';
import 'package:memox/core/database/tables/folders_table.dart';

class DecksTable extends Table {
  @override
  String get tableName => 'decks_table';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(
    min: DbConstants.minDeckNameLength,
    max: DbConstants.maxDeckNameLength,
  )();

  TextColumn get description => text().withDefault(const Constant(''))();

  IntColumn get folderId => integer().references(FoldersTable, #id)();

  IntColumn get colorValue =>
      integer().withDefault(const Constant(DbConstants.defaultColorValue))();

  TextColumn get tags => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get sortOrder =>
      integer().withDefault(const Constant(DbConstants.defaultSortOrder))();
}
