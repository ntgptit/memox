import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/guess/guess_engine.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/features/study/presentation/widgets/study_placeholder_view.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('study screen renders placeholder view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const StudyScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudyPlaceholderView), findsOneWidget);
  });

  testWidgets('study screen renders match mode when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 3,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          matchEngineProvider(
            3,
          ).overrideWithValue(MatchEngine(random: Random(1))),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.match),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Match'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.byType(StudyPlaceholderView), findsNothing);
  });

  testWidgets('study screen renders guess mode when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 3,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          guessEngineProvider(
            3,
          ).overrideWithValue(GuessEngine(random: Random(1))),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.guess),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guess'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.byType(StudyPlaceholderView), findsNothing);
  });

  testWidgets('study screen renders recall mode when requested', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 3,
                  front: '안녕하세요',
                  back: 'Hello',
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
          recallRandomProvider(3).overrideWithValue(Random(1)),
          recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.recall),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recall'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.byType(StudyPlaceholderView), findsNothing);
  });

  testWidgets('study screen renders fill mode when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 1,
                  deckId: 3,
                  front: 'Water',
                  back: 'banana',
                ),
              ],
            ),
          ),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          fillRandomProvider(3).overrideWithValue(Random(1)),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.fill),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Fill'), findsOneWidget);
    expect(find.text('Complete the blank'), findsOneWidget);
    expect(find.byType(StudyPlaceholderView), findsNothing);
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
