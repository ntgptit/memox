import 'package:drift/drift.dart';
import 'package:memox/core/database/tables/decks_table.dart';
import 'package:memox/core/design/study_mode.dart';

class StudySessionsTable extends Table {
  @override
  String get tableName => 'study_sessions_table';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get deckId => integer().references(DecksTable, #id)();

  IntColumn get mode => intEnum<StudyMode>()();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get completedAt => dateTime().nullable()();

  IntColumn get totalCards => integer()();

  IntColumn get correctCount => integer().withDefault(const Constant(0))();

  IntColumn get wrongCount => integer().withDefault(const Constant(0))();

  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
}
