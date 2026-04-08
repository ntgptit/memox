import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import '../../../../test_helpers/fakes/fake_card_review_dao.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';

void main() {
  ProviderContainer buildContainer({
    required FakeFlashcardRepository flashcardRepository,
    required FakeCardReviewDao cardReviewDao,
    _FakeStudyRepository? studyRepository,
  }) => ProviderContainer(
    overrides: [
      cardReviewDaoProvider.overrideWithValue(cardReviewDao),
      flashcardRepositoryProvider.overrideWithValue(flashcardRepository),
      studyRepositoryProvider.overrideWithValue(
        studyRepository ?? _FakeStudyRepository(),
      ),
      matchEngineProvider(1).overrideWithValue(MatchEngine(random: Random(1))),
    ],
  );

  test('same-column selection replaces the previous term selection', () async {
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(3)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final initial = await container.read(matchSessionProvider(1).future);
    final notifier = container.read(matchSessionProvider(1).notifier);

    await notifier.selectItem(initial.game.terms.first);
    await notifier.selectItem(initial.game.terms.last);

    final updated = container.read(matchSessionProvider(1)).requireValue;
    expect(updated.selectedTermId, initial.game.terms.last.id);
    expect(updated.selectedDefinitionId, isNull);
  });

  test('tapping the selected term again clears the selection', () async {
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final initial = await container.read(matchSessionProvider(1).future);
    final notifier = container.read(matchSessionProvider(1).notifier);
    final selectedTerm = initial.game.terms.first;

    await notifier.selectItem(selectedTerm);
    await notifier.selectItem(selectedTerm);

    final updated = container.read(matchSessionProvider(1)).requireValue;
    expect(updated.selectedTermId, isNull);
    expect(updated.selectedDefinitionId, isNull);
  });

  test('wrong selection increments mistakes and clears the pair', () async {
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);
    final initial = await container.read(matchSessionProvider(1).future);
    final notifier = container.read(matchSessionProvider(1).notifier);
    final term = initial.game.terms.first;
    final correctDefinitionId = initial.game.correctPairs[term.id]!;
    final wrongDefinition = initial.game.definitions.firstWhere(
      (item) => item.id != correctDefinitionId,
    );

    await notifier.selectItem(term);
    await notifier.selectItem(wrongDefinition);

    final updated = container.read(matchSessionProvider(1)).requireValue;
    expect(updated.mistakes, 1);
    expect(updated.comboCount, 0);
    expect(updated.selectedTermId, isNull);
    expect(updated.selectedDefinitionId, isNull);
  });

  test(
    'card matched after one mistake is persisted with a softer rating',
    () async {
      final flashcardRepository = FakeFlashcardRepository(cards: _cards(2));
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: flashcardRepository,
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final initial = await container.read(matchSessionProvider(1).future);
      final notifier = container.read(matchSessionProvider(1).notifier);
      final term = initial.game.terms.first;
      final correctDefinitionId = initial.game.correctPairs[term.id]!;
      final wrongDefinition = initial.game.definitions.firstWhere(
        (item) => item.id != correctDefinitionId,
      );
      final correctDefinition = initial.game.definitions.firstWhere(
        (item) => item.id == correctDefinitionId,
      );

      await notifier.selectItem(term);
      await notifier.selectItem(wrongDefinition);
      await notifier.selectItem(term);
      await notifier.selectItem(correctDefinition);

      expect(
        cardReviewDao.insertedReviews.single.rating.value,
        ReviewRating.good.index,
      );
    },
  );

  test(
    'correct selections complete the game when all pairs are matched',
    () async {
      final studyRepository = _FakeStudyRepository();
      final flashcardRepository = FakeFlashcardRepository(cards: _cards(1));
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: flashcardRepository,
        cardReviewDao: cardReviewDao,
        studyRepository: studyRepository,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final initial = await container.read(matchSessionProvider(1).future);
      final notifier = container.read(matchSessionProvider(1).notifier);
      final term = initial.game.terms.single;
      final definition = initial.game.definitions.single;

      await notifier.selectItem(term);
      await notifier.selectItem(definition);

      final updated = container.read(matchSessionProvider(1)).requireValue;
      final savedCard = await flashcardRepository.getById(1);
      expect(updated.isComplete, isTrue);
      expect(updated.matchedPairIds, <String>{term.id});
      expect(updated.comboCount, 1);
      expect(studyRepository.completedSession?.correctCount, 1);
      expect(studyRepository.completedSession?.mode, StudyMode.match);
      expect(savedCard?.status, isNot(CardStatus.newCard));
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
  StudySession? completedSession;

  @override
  Future<StudySession> completeSession(StudySession session) async =>
      completedSession = session;

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async => StudySession(
    id: 99,
    deckId: deckId,
    mode: mode,
    startedAt: DateTime(2026, 4, 3, 10),
  );

  @override
  Stream<List<StudySession>> watchAll() async* {
    yield const <StudySession>[];
  }
}
