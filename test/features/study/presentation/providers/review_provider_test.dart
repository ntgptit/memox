import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/support/flashcard_flags.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/review_provider.dart';
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
      if (srsEngine != null) srsEngineProvider.overrideWithValue(srsEngine),
    ],
  );

  test('toggleFlip flips the current card', () async {
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(reviewSessionProvider(1).notifier);

    final initial = await container.read(reviewSessionProvider(1).future);
    expect(initial.isFlipped, isFalse);

    await notifier.toggleFlip();

    final updated = container.read(reviewSessionProvider(1)).requireValue;
    expect(updated.isFlipped, isTrue);
  });

  test(
    'saved snapshot exposes review mode state, actions, and progress',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(reviewSessionProvider(1).notifier);
      final store = await container.read(
        activeStudySessionStoreProvider.future,
      );

      await container.read(reviewSessionProvider(1).future);
      var snapshot = store.load();
      expect(snapshot?.modePlan, const <StudyMode>[StudyMode.review]);
      expect(snapshot?.modeState, StudySessionModeState.initialized);
      expect(snapshot?.allowedActions, const <StudySessionAllowedAction>[
        StudySessionAllowedAction.revealAnswer,
      ]);
      expect(snapshot?.currentItem?.cardId, 1);
      expect(snapshot?.currentItem?.position, 1);
      expect(snapshot?.progress.completedCount, 0);
      expect(snapshot?.progress.totalCount, 2);

      await notifier.toggleFlip();

      snapshot = store.load();
      expect(snapshot?.modeState, StudySessionModeState.waitingFeedback);
      expect(snapshot?.allowedActions, const <StudySessionAllowedAction>[
        StudySessionAllowedAction.markRemembered,
        StudySessionAllowedAction.retryItem,
      ]);
    },
  );

  test('rate persists SRS data and advances to the next card', () async {
    final fixedNow = DateTime(2026, 4, 5, 10);
    final srsEngine = SRSEngine(now: () => fixedNow);
    final cardReviewDao = FakeCardReviewDao();
    final flashcardRepository = FakeFlashcardRepository(cards: _cards(2));
    final container = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
      srsEngine: srsEngine,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(reviewSessionProvider(1).notifier);
    final initial = await container.read(reviewSessionProvider(1).future);
    final expected = srsEngine.processReview(
      initial.currentCard!,
      ReviewRating.good,
    );

    await notifier.toggleFlip();
    await notifier.rate(ReviewRating.good);

    final updated = container.read(reviewSessionProvider(1)).requireValue;
    final savedCard = await flashcardRepository.getById(1);
    final review = cardReviewDao.insertedReviews.single;

    expect(updated.currentIndex, 1);
    expect(updated.isFlipped, isFalse);
    expect(updated.selectedRating, isNull);
    expect(savedCard?.easeFactor, expected.newEaseFactor);
    expect(savedCard?.interval, expected.newInterval);
    expect(savedCard?.repetitions, expected.newRepetitions);
    expect(savedCard?.nextReviewDate, expected.nextReviewDate);
    expect(savedCard?.status, expected.newStatus);
    expect(review.rating.value, ReviewRating.good.index);
    expect(review.isCorrect.value, isTrue);
  });

  test('empty deck produces empty state without session', () async {
    final cardReviewDao = FakeCardReviewDao();
    final studyRepository = _FakeStudyRepository();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(),
      cardReviewDao: cardReviewDao,
      studyRepository: studyRepository,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);

    final state = await container.read(reviewSessionProvider(1).future);

    expect(state.cards, isEmpty);
    expect(state.currentCard, isNull);
    expect(state.totalCards, 0);
    expect(state.isComplete, isFalse);
    expect(studyRepository.startedSession, isFalse);
  });

  test('rate is ignored when card is not flipped', () async {
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(reviewSessionProvider(1).notifier);
    await container.read(reviewSessionProvider(1).future);

    await notifier.rate(ReviewRating.good);

    final state = container.read(reviewSessionProvider(1)).requireValue;
    expect(state.currentIndex, 0);
    expect(state.results, isEmpty);
    expect(cardReviewDao.insertedReviews, isEmpty);
  });

  test(
    'restore clamps a stale review snapshot index to the last card',
    () async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 1,
            mode: StudyMode.review,
            session: StudySession(
              id: 41,
              deckId: 1,
              startedAt: DateTime(2026, 4, 5, 10),
            ),
            payload: <String, dynamic>{
              'cards': _cards(2).map((card) => card.toJson()).toList(),
              'currentIndex': 99,
              'nextReviewTimes': const <String, String>{},
              'isFlipped': true,
              'results': const <Map<String, dynamic>>[
                <String, dynamic>{'cardId': 99, 'rating': 'good'},
              ],
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

      final restored = await container.read(reviewSessionProvider(1).future);

      expect(restored.currentIndex, 1);
      expect(restored.currentCard?.id, 2);
      expect(restored.isFlipped, isFalse);
      expect(restored.results, isEmpty);
      expect(restored.retryPendingCardIds, isEmpty);
      expect(restored.nextReviewTimes, isNotEmpty);
    },
  );

  test('again rating re-queues the card for one retry round', () async {
    final cardReviewDao = FakeCardReviewDao();
    final studyRepository = _FakeStudyRepository();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(3)),
      cardReviewDao: cardReviewDao,
      studyRepository: studyRepository,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(reviewSessionProvider(1).notifier);

    await container.read(reviewSessionProvider(1).future);
    await _revealAndRate(notifier, ReviewRating.good);
    await _revealAndRate(notifier, ReviewRating.hard);
    await _revealAndRate(notifier, ReviewRating.again);

    var state = container.read(reviewSessionProvider(1)).requireValue;
    expect(state.isComplete, isFalse);
    expect(state.currentCard?.id, 3);
    expect(state.retryPendingCardIds, <int>{3});
    expect(state.results, hasLength(2));

    await _revealAndRate(notifier, ReviewRating.good);

    state = container.read(reviewSessionProvider(1)).requireValue;
    expect(state.isComplete, isTrue);
    expect(state.goodCount, 2);
    expect(state.hardCount, 1);
    expect(state.againCount, 0);
    expect(studyRepository.completedSession?.mode, StudyMode.review);
    expect(studyRepository.completedSession?.correctCount, 3);
    expect(studyRepository.completedSession?.wrongCount, 0);
  });

  test('completed review clears the active snapshot after rating', () async {
    final cardReviewDao = FakeCardReviewDao();
    final studyRepository = _FakeStudyRepository();
    final flashcardRepository = FakeFlashcardRepository(cards: _cards(1));
    final container = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
      studyRepository: studyRepository,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(reviewSessionProvider(1).notifier);
    final store = await container.read(activeStudySessionStoreProvider.future);

    await container.read(reviewSessionProvider(1).future);
    await _revealAndRate(notifier, ReviewRating.good);
    final state = container.read(reviewSessionProvider(1)).requireValue;
    final savedCard = await flashcardRepository.getById(1);

    expect(state.isComplete, isTrue);
    expect(state.results, hasLength(1));
    expect(state.results.single.cardId, 1);
    expect(state.results.single.rating, ReviewRating.good);
    expect(savedCard?.interval, greaterThan(0));
    expect(cardReviewDao.deletedReviewIds, isEmpty);
    expect(studyRepository.completedSession?.completedAt, isNotNull);
    expect(store.load(), isNull);
  });

  test('toggleFlag stores the reserved flag tag on the current card', () async {
    final cardReviewDao = FakeCardReviewDao();
    final flashcardRepository = FakeFlashcardRepository(cards: _cards(1));
    final container = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(reviewSessionProvider(1).notifier);

    await container.read(reviewSessionProvider(1).future);
    final isFlagged = await notifier.toggleFlag();
    final savedCard = await flashcardRepository.getById(1);

    expect(isFlagged, isTrue);
    expect(savedCard?.tags, contains(flaggedCardTag));
    expect(savedCard?.visibleTags, isEmpty);
  });

  test(
    'corrupted saved snapshot is ignored and a fresh session starts',
    () async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(<String, dynamic>{
          'deckId': 1,
          'mode': StudyMode.review.name,
          'session': const StudySession(id: 77, deckId: 1).toJson(),
          'payload': <String, dynamic>{
            'cards': [_cards(1).first.toJson()],
            'currentIndex': 0,
            'results': [
              <String, dynamic>{'cardId': 1, 'rating': 'unsupported-rating'},
            ],
            'retryPendingCardIds': const <int>[],
          },
        }),
      });
      final cardReviewDao = FakeCardReviewDao();
      final studyRepository = _FakeStudyRepository();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(1)),
        cardReviewDao: cardReviewDao,
        studyRepository: studyRepository,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);

      final state = await container.read(reviewSessionProvider(1).future);

      expect(studyRepository.startedSession, isTrue);
      expect(state.currentCard?.id, 1);
      expect(state.results, isEmpty);
    },
  );
}

Future<void> _revealAndRate(ReviewSession notifier, ReviewRating rating) async {
  await notifier.toggleFlip();
  await notifier.rate(rating);
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
  StudySession? completedSession;
  bool startedSession = false;

  @override
  Future<StudySession> completeSession(StudySession session) async =>
      completedSession = session;

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async {
    startedSession = true;
    return StudySession(
      id: 91,
      deckId: deckId,
      mode: mode,
      startedAt: DateTime(2026, 4, 5, 10),
    );
  }

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
