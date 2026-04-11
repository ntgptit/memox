import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/usecases/complete_study_session.dart';

void main() {
  test(
    'complete study session use case delegates session persistence',
    () async {
      final repository = _FakeStudyRepository();
      final useCase = CompleteStudySessionUseCase(repository);
      final completedAt = DateTime(2026, 4, 3, 11);

      final result = await useCase.call(
        StudySession(
          id: 3,
          deckId: 7,
          mode: StudyMode.match,
          startedAt: DateTime(2026, 4, 3, 10),
          completedAt: completedAt,
          totalCards: 5,
          correctCount: 5,
          wrongCount: 1,
          durationSeconds: 120,
        ),
      );

      expect(result, isA<Success<StudySession>>());
      expect(result.dataOrNull?.completedAt, completedAt);
      expect(repository.lastCompletedSession?.id, 3);
    },
  );
}

final class _FakeStudyRepository implements StudyRepository {
  StudySession? lastCompletedSession;

  @override
  Future<StudySession> completeSession(StudySession session) async {
    lastCompletedSession = session;
    return session;
  }

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async => StudySession(id: 1, deckId: deckId, mode: mode);

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
