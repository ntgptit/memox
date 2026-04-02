import 'package:isar/isar.dart';
import 'package:memox/features/study/data/models/study_session_model.dart';

abstract interface class StudyLocalDataSource {
  Stream<List<StudySessionModel>> watchAll();

  Future<StudySessionModel> save(StudySessionModel model);
}

final class StudyLocalDataSourceImpl implements StudyLocalDataSource {
  const StudyLocalDataSourceImpl(this._isar);

  final Isar _isar;

  @override
  Future<StudySessionModel> save(StudySessionModel model) async {
    return _isar.writeTxn(() async {
      final savedId = await _isar.studySessionModels.put(model);
      model.id = savedId;
      return model;
    });
  }

  @override
  Stream<List<StudySessionModel>> watchAll() {
    return _isar.studySessionModels.where().watch(fireImmediately: true);
  }
}
