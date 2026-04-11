import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
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
    _FakeStudyRepository? studyRepository,
    SRSEngine? srsEngine,
  }) => ProviderContainer(
    overrides: [
      flashcardRepositoryProvider.overrideWithValue(flashcardRepository),
      studyRepositoryProvider.overrideWithValue(
        studyRepository ?? _FakeStudyRepository(),
      ),
      cardReviewDaoProvider.overrideWithValue(cardReviewDao),
      fillRandomProvider(1).overrideWithValue(Random(1)),
      fillAutoAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
      fillWrongClearDelayProvider.overrideWith((ref) => Duration.zero),
      if (srsEngine != null) srsEngineProvider.overrideWithValue(srsEngine),
    ],
  );

  test('close answer can be accepted and saved as correct', () async {
    final cardReviewDao = FakeCardReviewDao();
    final flashcardRepository = FakeFlashcardRepository(cards: _cards(1));
    final srsEngine = SRSEngine(now: () => DateTime(2026, 4, 3, 10));
    final container = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
      srsEngine: srsEngine,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(fillSessionProvider(1).notifier);
    final initial = await container.read(fillSessionProvider(1).future);
    final expected = srsEngine.processFillResult(
      initial.currentCard!,
      isCorrect: true,
    );

    await notifier.updateInput('banan');
    await notifier.submitAnswer();

    var state = container.read(fillSessionProvider(1)).requireValue;
    expect(state.result, FillResult.close);

    await notifier.acceptClose();

    state = container.read(fillSessionProvider(1)).requireValue;
    final savedCard = await flashcardRepository.getById(1);
    final review = cardReviewDao.insertedReviews.single;

    expect(state.isComplete, isTrue);
    expect(state.acceptedCloseCount, 1);
    expect(state.bestStreak, 1);
    expect(savedCard?.easeFactor, expected.newEaseFactor);
    expect(savedCard?.interval, expected.newInterval);
    expect(savedCard?.repetitions, expected.newRepetitions);
    expect(savedCard?.status, expected.newStatus);
    expect(review.rating.value, ReviewRating.good.index);
    expect(review.userAnswer.value, 'banan');
  });

  test(
    'saved snapshot exposes fill mode state, actions, and progress',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(fillSessionProvider(1).notifier);
      final store = await container.read(
        activeStudySessionStoreProvider.future,
      );

      await container.read(fillSessionProvider(1).future);
      final initialState = container.read(fillSessionProvider(1)).requireValue;
      var snapshot = store.load();
      expect(snapshot?.modePlan, const <StudyMode>[StudyMode.fill]);
      expect(snapshot?.modeState, StudySessionModeState.initialized);
      expect(snapshot?.allowedActions, const <StudySessionAllowedAction>[
        StudySessionAllowedAction.submitAnswer,
      ]);
      expect(snapshot?.currentItem?.cardId, initialState.currentCard?.id);
      expect(snapshot?.progress.completedCount, 0);
      expect(snapshot?.progress.totalCount, 2);

      await notifier.updateInput('wrong');
      await notifier.submitAnswer();

      snapshot = store.load();
      expect(snapshot?.modeState, StudySessionModeState.retryPending);
      expect(snapshot?.allowedActions, const <StudySessionAllowedAction>[
        StudySessionAllowedAction.submitAnswer,
        StudySessionAllowedAction.goNext,
      ]);
    },
  );

  test(
    'initial prompt expects the answer side and shows the clue side',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);

      final state = await container.read(fillSessionProvider(1).future);

      expect(state.currentPrompt.correctAnswer, 'banana');
      expect(
        state.currentPrompt.sentenceWithBlank,
        'I ate a ________ for breakfast.',
      );
    },
  );

  test(
    'retry requires a matching answer before the card can advance',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(fillSessionProvider(1).notifier);

      await container.read(fillSessionProvider(1).future);
      await notifier.updateInput('apple');
      await notifier.submitAnswer();

      var state = container.read(fillSessionProvider(1)).requireValue;
      expect(state.isRetrying, isTrue);
      expect(state.currentIndex, 0);
      expect(state.retryCount, 1);
      expect(cardReviewDao.insertedReviews, hasLength(1));

      await notifier.updateInput('banana');
      await notifier.submitAnswer();

      state = container.read(fillSessionProvider(1)).requireValue;
      expect(state.isComplete, isTrue);
      expect(state.results.single.firstAttemptResult, FillResult.wrong);
      expect(state.results.single.retryCount, 1);
      expect(cardReviewDao.insertedReviews, hasLength(1));
    },
  );

  test('restore advances a completed fill card to the next prompt', () async {
    SharedPreferences.setMockInitialValues({
      'active_study_session_v1': jsonEncode(
        ActiveStudySessionSnapshot(
          deckId: 1,
          mode: StudyMode.fill,
          session: StudySession(
            id: 88,
            deckId: 1,
            mode: StudyMode.fill,
            startedAt: DateTime(2026, 4, 3, 10),
          ),
          payload: <String, dynamic>{
            'cards': _cards(2).map((card) => card.toJson()).toList(),
            'currentIndex': 0,
            'currentPrompt': const <String, dynamic>{
              'sentenceWithBlank': 'I ate a ________ for breakfast.',
              'correctAnswer': 'banana',
              'hint': 'Fruit',
              'answerLength': 6,
            },
            'userInput': 'banana',
            'result': FillResult.correct.name,
            'firstAttemptResult': FillResult.correct.name,
            'submittedAnswer': 'banana',
            'isRetrying': false,
            'retryCount': 0,
            'showHint': false,
            'results': const <Map<String, dynamic>>[
              <String, dynamic>{
                'cardId': '1',
                'firstAttemptResult': 'correct',
                'acceptedAsClose': false,
                'retryCount': 0,
              },
            ],
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

    final restored = await container.read(fillSessionProvider(1).future);

    expect(restored.currentIndex, 1);
    expect(restored.result, isNull);
    expect(restored.userInput, isEmpty);
    expect(restored.currentPrompt.correctAnswer, 'Answer 2');
  });

  test(
    'skip becomes available after the first retry and hints open automatically',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(fillSessionProvider(1).notifier);

      await container.read(fillSessionProvider(1).future);
      await notifier.updateInput('apple');
      await notifier.submitAnswer();

      var state = container.read(fillSessionProvider(1)).requireValue;
      expect(state.canSkip, isTrue);
      expect(state.retryCount, 1);
      expect(state.showHint, isTrue);

      await notifier.skipCard();

      state = container.read(fillSessionProvider(1)).requireValue;
      expect(state.isComplete, isTrue);
      expect(state.results.single.retryCount, 1);
    },
  );

  test(
    'streak increases on first-try correct answers and resets on wrong',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(3)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(fillSessionProvider(1).notifier);

      await container.read(fillSessionProvider(1).future);

      var state = container.read(fillSessionProvider(1)).requireValue;
      await notifier.updateInput(state.currentPrompt.correctAnswer);
      await notifier.submitAnswer();

      state = container.read(fillSessionProvider(1)).requireValue;
      expect(state.streak, 1);

      await notifier.updateInput(state.currentPrompt.correctAnswer);
      await notifier.submitAnswer();

      state = container.read(fillSessionProvider(1)).requireValue;
      expect(state.streak, 2);
      expect(state.bestStreak, 2);

      await notifier.updateInput('wrong');
      await notifier.submitAnswer();

      state = container.read(fillSessionProvider(1)).requireValue;
      expect(state.isRetrying, isTrue);
      expect(state.streak, 0);
      expect(state.bestStreak, 2);
    },
  );
}

List<FlashcardEntity> _cards(int count) => List<FlashcardEntity>.generate(
  count,
  (index) => FlashcardEntity(
    id: index + 1,
    deckId: 1,
    front: index == 0 ? 'banana' : 'Answer ${index + 1}',
    back: index == 0 ? 'Fruit ${index + 1}' : 'Clue ${index + 1}',
    example: index == 0 ? 'I ate a banana for breakfast.' : '',
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
    id: 88,
    deckId: deckId,
    mode: mode,
    startedAt: DateTime(2026, 4, 3, 10),
  );

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
