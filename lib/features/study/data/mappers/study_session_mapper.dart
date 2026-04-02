import 'package:isar/isar.dart';
import 'package:memox/features/study/data/models/study_session_model.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';

abstract final class StudySessionMapper {
  static StudySession toEntity(StudySessionModel model) {
    return StudySession(
      id: model.id,
      mode: model.mode,
    );
  }

  static StudySessionModel toModel(StudySession entity) {
    return StudySessionModel(
      id: entity.id > 0 ? entity.id : Isar.autoIncrement,
      mode: entity.mode,
    );
  }
}
