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
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  ProviderContainer buildContainer({
    required FakeFlashcardRepository flashcardRepository,
    required FakeCardReviewDao cardReviewDao,
  }) => ProviderContainer(
    overrides: [
      cardReviewDaoProvider.overrideWithValue(cardReviewDao),
      flashcardRepositoryProvider.overrideWithValue(flashcardRepository),
      studyRepositoryProvider.overrideWithValue(_FakeStudyRepository()),
      guessEngineProvider(1).overrideWithValue(GuessEngine(random: Random(1))),
      guessAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
    ],
  );

  test('streak tracking updates and preserves the best streak', () async {
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(3)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(guessSessionProvider(1).notifier);

    await container.read(guessSessionProvider(1).future);
    var state = container.read(guessSessionProvider(1)).requireValue;
    await notifier.selectOption(state.currentQuestion.correctIndex);

    state = container.read(guessSessionProvider(1)).requireValue;
    expect(state.streak, 1);
    expect(state.bestStreak, 1);

    await notifier.selectOption(state.currentQuestion.correctIndex);

    state = container.read(guessSessionProvider(1)).requireValue;
    expect(state.streak, 2);
    expect(state.bestStreak, 2);

    final wrongIndex = state.currentQuestion.correctIndex == 0 ? 1 : 0;
    await notifier.selectOption(wrongIndex);

    state = container.read(guessSessionProvider(1)).requireValue;
    expect(state.streak, 0);
    expect(state.bestStreak, 2);
    expect(state.results.map((result) => result.isCorrect).toList(), <bool>[
      true,
      true,
    ]);
    expect(state.results.every((result) => !result.skipped), isTrue);
    expect(state.retryPendingCardIds, <int>{state.currentCard!.id});
  });

  test(
    'saved snapshot exposes guess mode state, actions, and progress',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(guessSessionProvider(1).notifier);
      final store = await container.read(
        activeStudySessionStoreProvider.future,
      );

      await container.read(guessSessionProvider(1).future);
      final initialState = container.read(guessSessionProvider(1)).requireValue;
      var snapshot = store.load();
      expect(snapshot?.modePlan, const <StudyMode>[StudyMode.guess]);
      expect(snapshot?.modeState, StudySessionModeState.initialized);
      expect(snapshot?.allowedActions, const <StudySessionAllowedAction>[
        StudySessionAllowedAction.submitAnswer,
      ]);
      expect(snapshot?.currentItem?.cardId, initialState.currentCard?.id);
      expect(snapshot?.progress.completedCount, 0);
      expect(snapshot?.progress.totalCount, 2);

      final wrongIndex = initialState.currentQuestion.correctIndex == 0 ? 1 : 0;
      await notifier.selectOption(wrongIndex);

      snapshot = store.load();
      expect(snapshot?.modeState, StudySessionModeState.waitingFeedback);
      expect(snapshot?.allowedActions, const <StudySessionAllowedAction>[
        StudySessionAllowedAction.goNext,
      ]);
      expect(snapshot?.progress.completedCount, 0);
      expect(snapshot?.progress.totalCount, 2);
    },
  );

  test('skipQuestion re-queues the current card to the end', () async {
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(guessSessionProvider(1).notifier);
    final initial = await container.read(guessSessionProvider(1).future);
    final skippedCardId = initial.currentCard!.id;

    await notifier.skipQuestion();

    final updated = container.read(guessSessionProvider(1)).requireValue;
    expect(updated.cards.last.id, skippedCardId);
    expect(updated.currentCard?.id, isNot(skippedCardId));
  });

  test(
    'skipQuestion wraps to the first card when skipping the last card',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(guessSessionProvider(1).notifier);

      await container.read(guessSessionProvider(1).future);
      var state = container.read(guessSessionProvider(1)).requireValue;
      await notifier.selectOption(state.currentQuestion.correctIndex);

      state = container.read(guessSessionProvider(1)).requireValue;
      final skippedCardId = state.currentCard!.id;

      await notifier.skipQuestion();

      final updated = container.read(guessSessionProvider(1)).requireValue;
      expect(updated.currentCard?.id, isNot(skippedCardId));
      expect(updated.skipCounts[skippedCardId], 1);
    },
  );

  test(
    'clearing the saved snapshot and invalidating restarts guess progress',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(guessSessionProvider(1).notifier);

      await container.read(guessSessionProvider(1).future);
      final initialState = container.read(guessSessionProvider(1)).requireValue;
      await notifier.selectOption(initialState.currentQuestion.correctIndex);

      expect(
        container.read(guessSessionProvider(1)).requireValue.currentIndex,
        1,
      );

      final store = await container.read(
        activeStudySessionStoreProvider.future,
      );
      await store.clearIfMatches(deckId: 1, mode: StudyMode.guess);
      container.invalidate(guessSessionProvider(1));

      final restarted = await container.read(guessSessionProvider(1).future);

      expect(restarted.currentIndex, 0);
      expect(restarted.results, isEmpty);
    },
  );

  test(
    'restore clamps a stale guess snapshot and rebuilds the question',
    () async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 1,
            mode: StudyMode.guess,
            session: StudySession(
              id: 72,
              deckId: 1,
              mode: StudyMode.guess,
              startedAt: DateTime(2026, 4, 3, 10),
            ),
            payload: <String, dynamic>{
              'cards': _cards(2).map((card) => card.toJson()).toList(),
              'currentIndex': 99,
              'currentQuestion': <String, dynamic>{
                'definition': 'stale',
                'correctIndex': 99,
                'options': const <Map<String, dynamic>>[
                  <String, dynamic>{
                    'text': 'bad option',
                    'cardId': 'bad',
                    'isCorrect': true,
                  },
                ],
              },
              'selectedOptionIndex': 7,
              'isAnswered': true,
              'isCorrect': true,
              'results': const <Map<String, dynamic>>[
                <String, dynamic>{
                  'cardId': 99,
                  'isCorrect': true,
                  'skipped': false,
                },
              ],
              'skipCounts': const <String, int>{'99': 2},
              'retryPendingCardIds': const <int>[99],
            },
          ).toJson(),
        ),
      });

      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);

      final restored = await container.read(guessSessionProvider(1).future);

      expect(restored.currentIndex, 1);
      expect(restored.currentCard?.id, 2);
      expect(restored.currentQuestion.options, isNotEmpty);
      expect(restored.currentQuestion.correctIndex, inInclusiveRange(0, 3));
      expect(restored.isAnswered, isFalse);
      expect(restored.selectedOptionIndex, isNull);
      expect(restored.results, isEmpty);
      expect(restored.skipCounts, isEmpty);
      expect(restored.retryPendingCardIds, isEmpty);
    },
  );

  test(
    'wrong answer is retried once before being finalized as incorrect',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(guessSessionProvider(1).notifier);
      final initial = await container.read(guessSessionProvider(1).future);
      final firstCardId = initial.currentCard!.id;
      final wrongIndex = initial.currentQuestion.correctIndex == 0 ? 1 : 0;

      await notifier.selectOption(wrongIndex);

      var state = container.read(guessSessionProvider(1)).requireValue;
      expect(state.retryPendingCardIds, <int>{firstCardId});
      expect(state.results, isEmpty);

      await notifier.nextQuestion();
      state = container.read(guessSessionProvider(1)).requireValue;
      final retryWrongIndex = state.currentQuestion.correctIndex == 0 ? 1 : 0;
      await notifier.selectOption(retryWrongIndex);

      state = container.read(guessSessionProvider(1)).requireValue;
      expect(state.retryPendingCardIds, isEmpty);
      expect(state.results.single.cardId, firstCardId);
      expect(state.results.single.isCorrect, isFalse);
      expect(state.results.single.skipped, isFalse);
    },
  );

  test(
    'third skip queues a retry and the next skip finalizes the skipped card',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(guessSessionProvider(1).notifier);
      final initial = await container.read(guessSessionProvider(1).future);
      final skippedCardId = initial.currentCard!.id;

      await notifier.skipQuestion();
      await notifier.skipQuestion();
      await notifier.skipQuestion();

      var updated = container.read(guessSessionProvider(1)).requireValue;
      expect(updated.isAnswered, isTrue);
      expect(updated.isCorrect, isFalse);
      expect(updated.retryPendingCardIds, <int>{skippedCardId});
      expect(updated.results, isEmpty);

      await notifier.nextQuestion();
      await notifier.skipQuestion();

      updated = container.read(guessSessionProvider(1)).requireValue;
      expect(updated.isAnswered, isTrue);
      expect(updated.isCorrect, isFalse);
      expect(updated.skippedCount, 1);
      expect(updated.results.single.skipped, isTrue);
      expect(updated.results.single.cardId, skippedCardId);
      expect(cardReviewDao.insertedReviews, hasLength(2));
      expect(cardReviewDao.insertedReviews.last.isCorrect.value, isFalse);
    },
  );
}

List<FlashcardEntity> _cards(int count) => List<FlashcardEntity>.generate(
  count,
  (index) => FlashcardEntity(
    id: index + 1,
    deckId: 1,
    front: 'Term ${index + 1}',
    back: 'Definition ${index + 1}',
  ),
);

final class _FakeStudyRepository implements StudyRepository {
  @override
  Future<StudySession> completeSession(StudySession session) async => session;

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async => StudySession(
    id: 77,
    deckId: deckId,
    mode: mode,
    startedAt: DateTime(2026, 4, 3, 10),
  );

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
