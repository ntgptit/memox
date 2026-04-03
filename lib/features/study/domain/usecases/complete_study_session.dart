import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';

final class CompleteStudySessionUseCase {
  const CompleteStudySessionUseCase(this._repository);

  final StudyRepository _repository;

  Future<StudySession> call(StudySession session) =>
      _repository.completeSession(session);
}
