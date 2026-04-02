import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/usecases/start_study_session.dart';

void main() {
  test('start study session use case delegates selected mode', () async {
    final repository = _FakeStudyRepository();
    final useCase = StartStudySessionUseCase(repository);

    final result = await useCase.call(mode: StudyMode.match);

    expect(result.mode, StudyMode.match);
    expect(repository.lastMode, StudyMode.match);
  });
}

final class _FakeStudyRepository implements StudyRepository {
  StudyMode? lastMode;

  @override
  Future<StudySession> startSession(StudyMode mode) async {
    lastMode = mode;
    return StudySession(id: 1, mode: mode);
  }

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
