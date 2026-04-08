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
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
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
      false,
    ]);
    expect(state.results.every((result) => !result.skipped), isTrue);
  });

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
    'third skip marks the current card wrong instead of re-queuing again',
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

      final updated = container.read(guessSessionProvider(1)).requireValue;
      expect(updated.isAnswered, isTrue);
      expect(updated.isCorrect, isFalse);
      expect(updated.skippedCount, 1);
      expect(updated.results.single.skipped, isTrue);
      expect(updated.results.single.cardId, skippedCardId);
      expect(cardReviewDao.insertedReviews.single.isCorrect.value, isFalse);
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
