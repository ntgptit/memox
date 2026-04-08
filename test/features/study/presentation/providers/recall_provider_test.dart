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
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
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
      recallRandomProvider(1).overrideWithValue(Random(1)),
      recallAdvanceDelayProvider.overrideWith((ref) => Duration.zero),
      if (srsEngine != null) srsEngineProvider.overrideWithValue(srsEngine),
    ],
  );

  test('cannot reveal without typing', () async {
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

    var state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.isRevealed, isFalse);

    await notifier.updateAnswer('안');
    await notifier.revealAnswer();

    state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.isRevealed, isFalse);

    await notifier.updateAnswer('안녕하세요');
    await notifier.revealAnswer();

    state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.isRevealed, isTrue);
  });

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

  test('session stats are calculated from self-ratings', () async {
    final cardReviewDao = FakeCardReviewDao();
    final studyRepository = _FakeStudyRepository();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(3)),
      cardReviewDao: cardReviewDao,
      studyRepository: studyRepository,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);

    await container.read(recallSessionProvider(1).future);
    await _answerAndRate(notifier, 'First', SelfRating.gotIt);
    await _answerAndRate(notifier, 'Second', SelfRating.partial);
    await _answerAndRate(notifier, 'Third', SelfRating.missed);

    final state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.isComplete, isTrue);
    expect(state.gotItCount, 1);
    expect(state.partialCount, 1);
    expect(state.missedCount, 1);
    expect(studyRepository.completedSession?.mode, StudyMode.recall);
    expect(studyRepository.completedSession?.correctCount, 1);
    expect(studyRepository.completedSession?.wrongCount, 2);
  });

  test('reviewMissedCards restarts as a practice-only session', () async {
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final notifier = container.read(recallSessionProvider(1).notifier);

    await container.read(recallSessionProvider(1).future);
    await _answerAndRate(notifier, 'wrong', SelfRating.missed);
    await _answerAndRate(notifier, 'right', SelfRating.gotIt);
    await notifier.reviewMissedCards();

    final state = container.read(recallSessionProvider(1)).requireValue;
    expect(state.isMissedPracticeSession, isTrue);
    expect(state.totalCards, 1);
    expect(state.currentCard, isNotNull);
  });
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
  StudySession? completedSession;

  @override
  Future<StudySession> completeSession(StudySession session) async =>
      completedSession = session;

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
