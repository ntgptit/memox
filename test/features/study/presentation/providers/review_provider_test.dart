import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/review_provider.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
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

  test('completion stats reflect review ratings', () async {
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

    final state = container.read(reviewSessionProvider(1)).requireValue;

    expect(state.isComplete, isTrue);
    expect(state.goodCount, 1);
    expect(state.hardCount, 1);
    expect(state.againCount, 1);
    expect(studyRepository.completedSession?.mode, StudyMode.review);
    expect(studyRepository.completedSession?.correctCount, 2);
    expect(studyRepository.completedSession?.wrongCount, 1);
  });
}

Future<void> _revealAndRate(
  ReviewSession notifier,
  ReviewRating rating,
) async {
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
