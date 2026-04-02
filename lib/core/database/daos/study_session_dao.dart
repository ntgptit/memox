part of '../app_database.dart';

@DriftAccessor(tables: [StudySessionsTable])
class StudySessionDao extends DatabaseAccessor<AppDatabase>
    with _$StudySessionDaoMixin {
  StudySessionDao(super.db);

  Stream<List<StudySessionsTableData>> watchAll() {
    return (select(studySessionsTable)..orderBy([
          (StudySessionsTable tbl) => OrderingTerm.desc(tbl.startedAt),
        ]))
        .watch();
  }

  Future<List<StudySessionsTableData>> getAll() {
    return (select(studySessionsTable)..orderBy([
          (StudySessionsTable tbl) => OrderingTerm.desc(tbl.startedAt),
        ]))
        .get();
  }

  Future<StudySessionsTableData?> getById(int id) {
    return (select(
      studySessionsTable,
    )..where((StudySessionsTable tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertSession(StudySessionsTableCompanion session) {
    return into(
      studySessionsTable,
    ).insert(session, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateSession(StudySessionsTableCompanion session) {
    return update(studySessionsTable).replace(session);
  }

  Future<int> deleteAll() => delete(studySessionsTable).go();
}
