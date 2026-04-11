import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
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
      recallRandomProvider(1).overrideWithValue(Random(1)),
      recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
      if (srsEngine != null) srsEngineProvider.overrideWithValue(srsEngine),
    ],
  );

  test('can reveal immediately without typing', () async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);

    await container.read(recallSessionProvider(1).future);
    await notifier.revealAnswer();

    final state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.isRevealed, isTrue);
  });

  test(
    'saved snapshot exposes recall mode state, actions, and progress',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      addTearDown(cardReviewDao.dispose);
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(container.dispose);
      final notifier = container.read(recallSessionProvider(1).notifier);
      final store = await container.read(
        activeStudySessionStoreProvider.future,
      );

      await container.read(recallSessionProvider(1).future);
      final initialState = container
          .read(recallSessionProvider(1))
          .requireValue;
      var snapshot = store.load();
      expect(snapshot?.modePlan, const <StudyMode>[StudyMode.recall]);
      expect(snapshot?.modeState, StudySessionModeState.initialized);
      expect(snapshot?.allowedActions, const <StudySessionAllowedAction>[
        StudySessionAllowedAction.revealAnswer,
        StudySessionAllowedAction.retryItem,
      ]);
      expect(snapshot?.currentItem?.cardId, initialState.currentCard?.id);
      expect(snapshot?.progress.completedCount, 0);
      expect(snapshot?.progress.totalCount, 2);

      await notifier.revealAnswer();

      snapshot = store.load();
      expect(snapshot?.modeState, StudySessionModeState.waitingFeedback);
      expect(snapshot?.allowedActions, const <StudySessionAllowedAction>[
        StudySessionAllowedAction.markRemembered,
        StudySessionAllowedAction.retryItem,
      ]);
    },
  );

  test('markMissed advances without requiring typed input', () async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);

    await container.read(recallSessionProvider(1).future);
    await notifier.markMissed();

    final state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.currentIndex, 1);
    expect(state.results.single.rating, SelfRating.missed);
    expect(state.retryPendingCardIds, {state.results.single.cardId});
    expect(
      cardReviewDao.insertedReviews.single.selfRating.value,
      SelfRating.missed.index,
    );
  });

  test('self-rating advances to the next card', () async {
    final cardReviewDao = FakeCardReviewDao();
    addTearDown(cardReviewDao.dispose);
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);

    await container.read(recallSessionProvider(1).future);
    await notifier.updateAnswer('Remembered');
    await notifier.revealAnswer();
    await notifier.rateSelf(SelfRating.gotIt);

    final state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.currentIndex, 1);
    expect(state.userAnswer, isEmpty);
    expect(state.isRevealed, isFalse);
    expect(state.selfRating, isNull);
    expect(state.results, hasLength(1));
  });

  test('SRS updates match the selected self-rating mapping', () async {
    final fixedNow = DateTime(2026, 4, 3, 10);
    final srsEngine = SRSEngine(now: () => fixedNow);
    final cardReviewDao = FakeCardReviewDao();
    final flashcardRepository = FakeFlashcardRepository(cards: _cards(1));
    addTearDown(cardReviewDao.dispose);
    final container = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
      srsEngine: srsEngine,
    );
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);
    final initial = await container.read(recallSessionProvider(1).future);
    final expected = srsEngine.processRecallSelfRating(
      initial.currentCard!,
      SelfRating.partial,
    );

    await notifier.updateAnswer('Some answer');
    await notifier.revealAnswer();
    await notifier.rateSelf(SelfRating.partial);

    final savedCard = await flashcardRepository.getById(1);
    final review = cardReviewDao.insertedReviews.single;
    expect(savedCard?.easeFactor, expected.newEaseFactor);
    expect(savedCard?.interval, expected.newInterval);
    expect(savedCard?.repetitions, expected.newRepetitions);
    expect(savedCard?.nextReviewDate, expected.nextReviewDate);
    expect(savedCard?.status, expected.newStatus);
    expect(review.rating.value, ReviewRating.hard.index);
    expect(review.selfRating.value, SelfRating.partial.index);
    expect(review.userAnswer.value, 'Some answer');
  });

  test('missed cards stay in-session until the retry is resolved', () async {
    final cardReviewDao = FakeCardReviewDao();
    final studyRepository = _FakeStudyRepository();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
      cardReviewDao: cardReviewDao,
      studyRepository: studyRepository,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);

    await container.read(recallSessionProvider(1).future);
    await notifier.markMissed();
    await _answerAndRate(notifier, 'Recovered', SelfRating.gotIt);

    final state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.isComplete, isFalse);
    expect(state.retryPendingCardIds, {
      state.results
          .firstWhere((result) => result.rating == SelfRating.missed)
          .cardId,
    });
    expect(studyRepository.latestCompletedSession, isNull);
  });

  test('retry success replaces the missed result before completion', () async {
    final cardReviewDao = FakeCardReviewDao();
    final studyRepository = _FakeStudyRepository();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
      cardReviewDao: cardReviewDao,
      studyRepository: studyRepository,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);

    await container.read(recallSessionProvider(1).future);
    await notifier.markMissed();
    await _answerAndRate(notifier, 'Recovered', SelfRating.gotIt);

    final state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.isComplete, isTrue);
    expect(state.gotItCount, 1);
    expect(state.partialCount, 0);
    expect(state.missedCount, 0);
    expect(state.results.single.rating, SelfRating.gotIt);
    expect(studyRepository.latestCompletedSession?.mode, StudyMode.recall);
    expect(studyRepository.latestCompletedSession?.correctCount, 1);
    expect(studyRepository.latestCompletedSession?.wrongCount, 0);
  });

  test(
    'second miss finalizes the card as missed and completes the session',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final studyRepository = _FakeStudyRepository();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
        cardReviewDao: cardReviewDao,
        studyRepository: studyRepository,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(recallSessionProvider(1).notifier);

      await container.read(recallSessionProvider(1).future);
      await notifier.markMissed();
      await notifier.markMissed();

      final state = container.read(recallSessionProvider(1)).requireValue;
      expect(state.isComplete, isTrue);
      expect(state.retryPendingCardIds, isEmpty);
      expect(state.missedCount, 1);
      expect(state.results.single.rating, SelfRating.missed);
      expect(studyRepository.latestCompletedSession?.wrongCount, 1);
    },
  );

  test('retry pending state survives snapshot restore', () async {
    final cardReviewDao = FakeCardReviewDao();
    final flashcardRepository = FakeFlashcardRepository(cards: _cards(2));
    final container = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);

    await container.read(recallSessionProvider(1).future);
    await notifier.markMissed();
    final pendingCardId = container
        .read(recallSessionProvider(1))
        .requireValue
        .retryPendingCardIds
        .single;

    final restoredContainer = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
    );
    addTearDown(restoredContainer.dispose);

    final restoredState = await restoredContainer.read(
      recallSessionProvider(1).future,
    );
    expect(restoredState.isComplete, isFalse);
    expect(restoredState.retryPendingCardIds, {pendingCardId});
    expect(restoredState.results.single.rating, SelfRating.missed);
  });

  test(
    'restore advances a rated recall card instead of trapping the session',
    () async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 1,
            mode: StudyMode.recall,
            session: StudySession(
              id: 81,
              deckId: 1,
              mode: StudyMode.recall,
              startedAt: DateTime(2026, 4, 3, 10),
            ),
            payload: <String, dynamic>{
              'cards': _cards(2).map((card) => card.toJson()).toList(),
              'currentIndex': 0,
              'userAnswer': 'Recovered',
              'isRevealed': true,
              'selfRating': SelfRating.gotIt.name,
              'results': const <Map<String, dynamic>>[
                <String, dynamic>{
                  'cardId': 1,
                  'userAnswer': 'Recovered',
                  'rating': 'gotIt',
                },
              ],
              'retryPendingCardIds': const <int>[],
              'attemptCounts': const <String, int>{'1': 1},
            },
          ).toJson(),
        ),
      });

      final cardReviewDao = FakeCardReviewDao();
      final studyRepository = _FakeStudyRepository();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
        studyRepository: studyRepository,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);

      final restored = await container.read(recallSessionProvider(1).future);

      expect(restored.isComplete, isFalse);
      expect(restored.currentIndex, 1);
      expect(restored.currentCard?.id, 2);
      expect(restored.userAnswer, isEmpty);
      expect(restored.isRevealed, isFalse);
      expect(restored.selfRating, isNull);
      expect(studyRepository.latestCompletedSession, isNull);
    },
  );
}

Future<void> _answerAndRate(
  RecallSession notifier,
  String answer,
  SelfRating rating,
) async {
  await notifier.updateAnswer(answer);
  await notifier.revealAnswer();
  await notifier.rateSelf(rating);
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
  final List<StudySession> completedSessions = <StudySession>[];

  StudySession? get latestCompletedSession =>
      completedSessions.isEmpty ? null : completedSessions.last;

  @override
  Future<StudySession> completeSession(StudySession session) async {
    completedSessions.add(session);
    return session;
  }

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async => StudySession(
    id: 55,
    deckId: deckId,
    mode: mode,
    startedAt: DateTime(2026, 4, 3, 10),
  );

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
