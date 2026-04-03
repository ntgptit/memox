part of '../app_database.dart';

@DriftAccessor(tables: [StudySessionsTable])
class StudySessionDao extends DatabaseAccessor<AppDatabase>
    with _$StudySessionDaoMixin {
  StudySessionDao(super.db);

  Stream<List<StudySessionsTableData>> watchAll() => (select(studySessionsTable)..orderBy([
          (StudySessionsTable tbl) => OrderingTerm.desc(tbl.startedAt),
        ]))
        .watch();

  Future<List<StudySessionsTableData>> getAll() => (select(studySessionsTable)..orderBy([
          (StudySessionsTable tbl) => OrderingTerm.desc(tbl.startedAt),
        ]))
        .get();

  Future<StudySessionsTableData?> getById(int id) => (select(
      studySessionsTable,
    )..where((StudySessionsTable tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertSession(StudySessionsTableCompanion session) => into(
      studySessionsTable,
    ).insert(session, mode: InsertMode.insertOrReplace);

  Future<bool> updateSession(StudySessionsTableCompanion session) => update(studySessionsTable).replace(session);

  Future<int> deleteAll() => delete(studySessionsTable).go();
}
