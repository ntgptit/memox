import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';

final class StartStudySessionUseCase {
  const StartStudySessionUseCase(this._repository);

  final StudyRepository _repository;

  Future<StudySession> call({String mode = 'review'}) {
    return _repository.startSession(mode);
  }
}
