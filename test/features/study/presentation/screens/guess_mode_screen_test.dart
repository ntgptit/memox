import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/guess/guess_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/screens/guess_mode_screen.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('GuessModeScreen renders the current question', (tester) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guess'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('GuessModeScreen shows completion after a correct answer', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 5,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            5,
          ).overrideWithValue(GuessEngine(random: Random(1))),
          guessAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(home: const GuessModeScreen(deckId: 5)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('안녕하세요'));
    await tester.pumpAndSettle();

    expect(find.text('Guess complete'), findsOneWidget);
    expect(find.text('1/1 correct (100%)'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}

final class _FakeStudyRepository implements StudyRepository {
  @override
  Future<StudySession> completeSession(StudySession session) async => session;

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async => StudySession(
    id: 1,
    deckId: deckId,
    mode: mode,
    startedAt: DateTime(2026, 4, 3, 10),
  );

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
