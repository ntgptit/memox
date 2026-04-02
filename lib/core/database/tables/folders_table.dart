import 'package:drift/drift.dart';
import 'package:memox/core/database/db_constants.dart';

class FoldersTable extends Table {
  @override
  String get tableName => 'folders_table';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(
    min: DbConstants.minFolderNameLength,
    max: DbConstants.maxFolderNameLength,
  )();

  IntColumn get parentId =>
      integer().nullable().references(FoldersTable, #id)();

  IntColumn get colorValue =>
      integer().withDefault(const Constant(DbConstants.defaultColorValue))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get sortOrder =>
      integer().withDefault(const Constant(DbConstants.defaultSortOrder))();
}
