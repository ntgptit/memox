import 'package:memox/core/database/app_database.dart';

abstract interface class StudyLocalDataSource {
  Stream<List<StudySessionsTableData>> watchAll();

  Future<StudySessionsTableData> save(StudySessionsTableCompanion companion);
}

final class StudyLocalDataSourceImpl implements StudyLocalDataSource {
  const StudyLocalDataSourceImpl(this._studySessionDao);

  final StudySessionDao _studySessionDao;

  @override
  Future<StudySessionsTableData> save(
    StudySessionsTableCompanion companion,
  ) async {
    final insertedId = await _studySessionDao.insertSession(companion);
    final targetId = companion.id.present ? companion.id.value : insertedId;
    final saved = await _studySessionDao.getById(targetId);
    if (saved != null) {
      return saved;
    }
    throw StateError('Unable to read saved study session $targetId');
  }

  @override
  Stream<List<StudySessionsTableData>> watchAll() =>
      _studySessionDao.watchAll();
}
