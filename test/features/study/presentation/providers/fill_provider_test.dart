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
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
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

  test('retry requires a matching answer before the card can advance', () async {
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
  });

  test('skip only becomes available after two failed retries', () async {
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
    expect(state.canSkip, isFalse);

    await notifier.updateInput('pear');
    await notifier.submitAnswer();

    state = container.read(fillSessionProvider(1)).requireValue;
    expect(state.canSkip, isTrue);
    expect(state.retryCount, 2);

    await notifier.skipCard();

    state = container.read(fillSessionProvider(1)).requireValue;
    expect(state.isComplete, isTrue);
    expect(state.results.single.retryCount, 2);
  });

  test('streak increases on first-try correct answers and resets on wrong', () async {
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
  });
}

List<FlashcardEntity> _cards(int count) => List<FlashcardEntity>.generate(
  count,
  (index) => FlashcardEntity(
    id: index + 1,
    deckId: 1,
    front: 'Term ${index + 1}',
    back: index == 0 ? 'banana' : 'Answer ${index + 1}',
    example: index == 0 ? 'The answer is banana.' : '',
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
