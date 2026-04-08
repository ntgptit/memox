import 'dart:convert';
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
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/features/study/presentation/widgets/study_placeholder_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_deck_repository.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('study screen renders placeholder view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const StudyScreen())),
    );
    await _pumpStudyScreen(tester);

    expect(find.byType(StudyPlaceholderView), findsOneWidget);
  });

  testWidgets('study screen renders match mode when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
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
    await _pumpStudyScreen(tester);

    expect(find.text('Match'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.byType(StudyPlaceholderView), findsNothing);
  });

  testWidgets('study screen renders review mode when requested', (
    tester,
  ) async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.review),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.byType(StudyPlaceholderView), findsNothing);
  });

  testWidgets('study screen renders guess mode when requested', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
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
    await _pumpStudyScreen(tester);

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
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
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
    await _pumpStudyScreen(tester);

    expect(find.text('Recall'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
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
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
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

  testWidgets('study screen prompts to resume an active session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        ActiveStudySessionSnapshot(
          deckId: 3,
          mode: StudyMode.review,
          session: StudySession(
            id: 1,
            deckId: 3,
            startedAt: DateTime(2026, 4, 3, 10),
          ),
          payload: <String, dynamic>{
            'cards': <Map<String, dynamic>>[_singleCard.toJson()],
            'currentIndex': 0,
            'nextReviewTimes': const <String, String>{},
            'isFlipped': false,
            'results': const <Map<String, dynamic>>[
              <String, dynamic>{'cardId': 1, 'rating': 'good'},
            ],
          },
        ).toJson(),
      ),
    });

    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(cards: const [_singleCard]),
          ),
          deckRepositoryProvider.overrideWithValue(FakeDeckRepository()),
          studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
          cardReviewDaoProvider.overrideWithValue(cardReviewDao),
        ],
        child: buildTestApp(
          home: const StudyScreen(deckId: 3, mode: StudyMode.review),
        ),
      ),
    );
    await _pumpStudyScreen(tester);

    expect(find.text('Resume session?'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Start over'), findsOneWidget);

    await tester.tap(find.text('Start over'));
    await _pumpStudyScreen(tester);

    expect(find.text('Resume session?'), findsNothing);
  });
}

const FlashcardEntity _singleCard = FlashcardEntity(
  id: 1,
  deckId: 3,
  front: '안녕하세요',
  back: 'Hello',
);

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

Future<void> _pumpStudyScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}
