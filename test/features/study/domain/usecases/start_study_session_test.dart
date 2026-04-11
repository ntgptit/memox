import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/usecases/start_study_session.dart';

void main() {
  test('start study session use case delegates selected mode', () async {
    final repository = _FakeStudyRepository();
    final useCase = StartStudySessionUseCase(repository);

    final result = await useCase.call(deckId: 7, mode: StudyMode.match);

    expect(result, isA<Success<StudySession>>());
    expect(result.dataOrNull?.mode, StudyMode.match);
    expect(result.dataOrNull?.deckId, 7);
    expect(repository.lastDeckId, 7);
    expect(repository.lastMode, StudyMode.match);
  });
}

final class _FakeStudyRepository implements StudyRepository {
  int? lastDeckId;
  StudyMode? lastMode;

  @override
  Future<StudySession> completeSession(StudySession session) async => session;

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async {
    lastDeckId = deckId;
    lastMode = mode;
    return StudySession(id: 1, deckId: deckId, mode: mode);
  }

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
