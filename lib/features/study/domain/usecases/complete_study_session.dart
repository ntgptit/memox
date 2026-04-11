import 'package:memox/core/types/result.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';

final class CompleteStudySessionUseCase {
  const CompleteStudySessionUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<StudySession>> call(StudySession session) async {
    final completedSession = await _repository.completeSession(session);
    return Result<StudySession>.success(completedSession);
  }
}
