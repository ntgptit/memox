import 'dart:convert';
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
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
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

  test(
    'saved snapshot exposes match mode state, actions, and progress',
    () async {
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(2)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final store = await container.read(
        activeStudySessionStoreProvider.future,
      );

      final initial = await container.read(matchSessionProvider(1).future);
      var snapshot = store.load();
      expect(snapshot?.modePlan, const <StudyMode>[StudyMode.match]);
      expect(snapshot?.modeState, StudySessionModeState.initialized);
      expect(snapshot?.allowedActions, isEmpty);
      expect(snapshot?.currentItem?.position, 1);
      expect(snapshot?.currentItem?.cardId, isNotNull);
      expect(snapshot?.progress.completedCount, 0);
      expect(snapshot?.progress.totalCount, 2);

      final notifier = container.read(matchSessionProvider(1).notifier);
      await notifier.selectItem(initial.game.terms.first);

      snapshot = store.load();
      expect(snapshot?.modeState, StudySessionModeState.inProgress);
      expect(snapshot?.allowedActions, isEmpty);
    },
  );

  test('tapping the selected term again keeps the selection', () async {
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
    expect(updated.selectedTermId, selectedTerm.id);
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

  test(
    'deck sizes beyond the board cap continue into the next board',
    () async {
      final studyRepository = _FakeStudyRepository();
      final flashcardRepository = FakeFlashcardRepository(cards: _cards(6));
      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: flashcardRepository,
        cardReviewDao: cardReviewDao,
        studyRepository: studyRepository,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);
      final initial = await container.read(matchSessionProvider(1).future);

      expect(initial.totalPairs, 6);
      expect(initial.totalBoards, 2);
      expect(initial.game.correctPairs.length, 5);

      await _solveCurrentBoard(container);

      final secondBoard = container.read(matchSessionProvider(1)).requireValue;
      expect(secondBoard.isComplete, isFalse);
      expect(secondBoard.boardIndex, 1);
      expect(secondBoard.completedPairCount, 5);
      expect(secondBoard.matchedCount, 5);
      expect(secondBoard.game.correctPairs.length, 1);

      await _solveCurrentBoard(container);

      final completed = container.read(matchSessionProvider(1)).requireValue;
      expect(completed.isComplete, isTrue);
      expect(completed.matchedCount, 6);
      expect(studyRepository.completedSession?.totalCards, 6);
    },
  );

  test('grouped-board progress survives snapshot restore', () async {
    final flashcardRepository = FakeFlashcardRepository(cards: _cards(6));
    final cardReviewDao = FakeCardReviewDao();
    final container = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
    );
    addTearDown(cardReviewDao.dispose);
    addTearDown(container.dispose);

    await container.read(matchSessionProvider(1).future);
    await _solveCurrentBoard(container);

    final restoredContainer = buildContainer(
      flashcardRepository: flashcardRepository,
      cardReviewDao: cardReviewDao,
    );
    addTearDown(restoredContainer.dispose);

    final restoredState = await restoredContainer.read(
      matchSessionProvider(1).future,
    );
    expect(restoredState.isComplete, isFalse);
    expect(restoredState.boardIndex, 1);
    expect(restoredState.completedPairCount, 5);
    expect(restoredState.matchedCount, 5);
    expect(restoredState.game.correctPairs.length, 1);
  });

  test(
    'restore advances a fully matched board instead of trapping the mode',
    () async {
      final engine = MatchEngine(random: Random(1));
      final cards = engine.shuffleCards(_cards(6));
      final firstBoardCards = cards
          .take(MatchEngine.defaultPairsPerRound)
          .toList(growable: false);
      final firstBoard = engine.generateGame(
        firstBoardCards,
        pairsPerRound: firstBoardCards.length,
      );

      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': jsonEncode(
          ActiveStudySessionSnapshot(
            deckId: 1,
            mode: StudyMode.match,
            session: StudySession(
              id: 99,
              deckId: 1,
              mode: StudyMode.match,
              startedAt: DateTime(2026, 4, 3, 10),
            ),
            payload: <String, dynamic>{
              'cards': cards.map((card) => card.toJson()).toList(),
              'game': <String, dynamic>{
                'terms': firstBoard.terms
                    .map(
                      (item) => <String, dynamic>{
                        'id': item.id,
                        'text': item.text,
                        'type': item.type.name,
                      },
                    )
                    .toList(),
                'definitions': firstBoard.definitions
                    .map(
                      (item) => <String, dynamic>{
                        'id': item.id,
                        'text': item.text,
                        'type': item.type.name,
                      },
                    )
                    .toList(),
                'correctPairs': firstBoard.correctPairs,
              },
              'startTime': DateTime(2026, 4, 3, 10).toIso8601String(),
              'boardIndex': 0,
              'completedPairCount': 0,
              'matchedPairIds': firstBoard.correctPairs.keys.toList(),
              'attemptCounts': const <String, int>{},
              'mistakes': 0,
              'comboCount': 5,
            },
          ).toJson(),
        ),
      });

      final cardReviewDao = FakeCardReviewDao();
      final container = buildContainer(
        flashcardRepository: FakeFlashcardRepository(cards: _cards(6)),
        cardReviewDao: cardReviewDao,
      );
      addTearDown(cardReviewDao.dispose);
      addTearDown(container.dispose);

      final restored = await container.read(matchSessionProvider(1).future);

      expect(restored.isComplete, isFalse);
      expect(restored.boardIndex, 1);
      expect(restored.completedPairCount, 5);
      expect(restored.matchedPairIds, isEmpty);
      expect(restored.game.correctPairs.length, 1);
    },
  );
}

Future<void> _solveCurrentBoard(ProviderContainer container) async {
  final notifier = container.read(matchSessionProvider(1).notifier);
  final state = container.read(matchSessionProvider(1)).requireValue;

  for (final term in state.game.terms) {
    if (state.matchedPairIds.contains(term.id)) {
      continue;
    }

    final definitionId = state.game.correctPairs[term.id]!;
    final definition = state.game.definitions.firstWhere(
      (item) => item.id == definitionId,
    );
    await notifier.selectItem(term);
    await notifier.selectItem(definition);
  }
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
