import 'package:drift/drift.dart' show Value;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
import 'package:memox/features/study/presentation/support/study_restore_utils.dart';
import 'package:memox/features/study/presentation/support/study_session_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'match_provider.freezed.dart';
part 'match_provider.g.dart';

enum MatchAttemptOutcome { correct, wrong }

@freezed
abstract class MatchAttemptResult with _$MatchAttemptResult {
  const factory MatchAttemptResult({
    required MatchAttemptOutcome outcome,
    required String termId,
    required String definitionId,
    required int sequence,
  }) = _MatchAttemptResult;
}

@freezed
abstract class MatchState with _$MatchState {
  const factory MatchState({
    required List<FlashcardEntity> cards,
    required ({
      List<({String id, String text, MatchItemType type})> terms,
      List<({String id, String text, MatchItemType type})> definitions,
      Map<String, String> correctPairs,
    })
    game,
    required DateTime startTime,
    @Default(0) int boardIndex,
    @Default(0) int completedPairCount,
    String? selectedTermId,
    String? selectedDefinitionId,
    @Default(<String>{}) Set<String> matchedPairIds,
    @Default(<String, int>{}) Map<String, int> attemptCounts,
    @Default(0) int mistakes,
    @Default(false) bool isComplete,
    MatchAttemptResult? lastResult,
    @Default(0) int comboCount,
  }) = _MatchState;
}

extension MatchStateX on MatchState {
  int get totalPairs => cards.length;

  int get matchedCount => completedPairCount + matchedPairIds.length;

  int get pairsLeft => totalPairs - matchedCount;

  int get totalBoards {
    if (cards.isEmpty) {
      return 0;
    }

    return (cards.length / MatchEngine.defaultPairsPerRound).ceil();
  }

  bool isDefinitionMatched(String definitionId) {
    for (final termId in matchedPairIds) {
      if (game.correctPairs[termId] == definitionId) {
        return true;
      }
    }

    return false;
  }

  List<StudySessionAllowedAction> get allowedActions {
    if (isComplete) {
      return const <StudySessionAllowedAction>[];
    }

    if (lastResult != null) {
      return const <StudySessionAllowedAction>[];
    }

    if (selectedTermId != null && selectedDefinitionId != null) {
      return const <StudySessionAllowedAction>[
        StudySessionAllowedAction.submitAnswer,
      ];
    }

    return const <StudySessionAllowedAction>[];
  }

  ActiveStudySessionCurrentItem? get currentItemSnapshot {
    if (cards.isEmpty) {
      return null;
    }

    return ActiveStudySessionCurrentItem(
      position: boardIndex + 1,
      cardId: _currentBoardCardId,
    );
  }

  StudySessionModeState get modeState {
    if (isComplete) {
      return StudySessionModeState.completed;
    }

    if (lastResult != null) {
      return StudySessionModeState.waitingFeedback;
    }

    if (boardIndex == 0 &&
        completedPairCount == 0 &&
        matchedPairIds.isEmpty &&
        selectedTermId == null &&
        selectedDefinitionId == null) {
      return StudySessionModeState.initialized;
    }

    return StudySessionModeState.inProgress;
  }

  ActiveStudySessionProgress get progressSnapshot => ActiveStudySessionProgress(
    completedCount: matchedCount,
    totalCount: totalPairs,
  );

  int? get _currentBoardCardId {
    if (game.correctPairs.isEmpty) {
      return null;
    }

    final firstTermId = game.correctPairs.keys.first;
    final rawId = firstTermId.replaceFirst('term-', '');
    return int.tryParse(rawId);
  }
}

MatchState? _stateValueOrNull(AsyncValue<MatchState> value) => switch (value) {
  AsyncData<MatchState>(:final value) => value,
  _ => null,
};

@riverpod
MatchEngine matchEngine(Ref ref, int deckId) => MatchEngine();

@Riverpod(keepAlive: true)
class MatchSession extends _$MatchSession {
  final Map<String, FlashcardEntity> _cardsByTermId =
      <String, FlashcardEntity>{};
  StudySession? _session;
  var _attemptSequence = 0;

  @override
  Future<MatchState> build(int deckId) async {
    final restored = await _restoreSnapshot();

    if (restored != null) {
      return restored;
    }

    return _startGame(deckId);
  }

  Future<void> selectItem(
    ({String id, String text, MatchItemType type}) item,
  ) async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete || current.lastResult != null) {
      return;
    }

    if (_isMatched(current, item)) {
      return;
    }

    if (item.type == MatchItemType.term) {
      final updated = current.copyWith(selectedTermId: item.id);
      state = AsyncValue<MatchState>.data(updated);
      await _persistSnapshot(updated);
      await _resolveSelection(updated);
      return;
    }

    final updated = current.copyWith(selectedDefinitionId: item.id);
    state = AsyncValue<MatchState>.data(updated);
    await _persistSnapshot(updated);
    await _resolveSelection(updated);
  }

  Future<void> startGame() async {
    state = const AsyncValue<MatchState>.loading();
    final nextState = await _startGame(deckId);
    state = AsyncValue<MatchState>.data(nextState);
  }

  bool _isMatched(
    MatchState current,
    ({String id, String text, MatchItemType type}) item,
  ) {
    if (item.type == MatchItemType.term) {
      return current.matchedPairIds.contains(item.id);
    }

    return current.isDefinitionMatched(item.id);
  }

  Future<void> _completeGame(MatchState current) async {
    final session = _session;

    if (session == null) {
      return;
    }

    final completedSession = session.copyWith(
      completedAt: DateTime.now(),
      totalCards: current.totalPairs,
      correctCount: current.totalPairs,
      wrongCount: current.mistakes,
      durationSeconds: DateTime.now().difference(current.startTime).inSeconds,
    );
    _session = unwrapStudySessionResult(
      await ref
          .read(completeStudySessionUseCaseProvider)
          .call(completedSession),
    );
    await _clearSnapshot();
  }

  Future<void> _handleCorrect(
    MatchState current,
    String termId,
    String definitionId,
  ) async {
    final result = MatchAttemptResult(
      outcome: MatchAttemptOutcome.correct,
      termId: termId,
      definitionId: definitionId,
      sequence: ++_attemptSequence,
    );
    final matchedPairIds = <String>{...current.matchedPairIds, termId};
    state = AsyncValue<MatchState>.data(
      current.copyWith(
        matchedPairIds: matchedPairIds,
        comboCount: current.comboCount + 1,
        lastResult: result,
      ),
    );
    await _persistSnapshot(state.requireValue);
    await _persistMatchReview(termId, (current.attemptCounts[termId] ?? 0) + 1);
    await Future<void>.delayed(DurationTokens.chartDraw);
    final latest = _stateValueOrNull(state);

    if (!_isCurrentAttempt(latest, result.sequence)) {
      return;
    }

    final boardCompleted =
        matchedPairIds.length == latest!.game.correctPairs.length;
    final cleared = latest.copyWith(
      selectedTermId: null,
      selectedDefinitionId: null,
      lastResult: null,
    );

    if (!boardCompleted) {
      state = AsyncValue<MatchState>.data(cleared);
      await _persistSnapshot(cleared);
      return;
    }

    if (cleared.boardIndex < cleared.totalBoards - 1) {
      final nextState = _nextBoardState(cleared);
      state = AsyncValue<MatchState>.data(nextState);
      await _persistSnapshot(nextState);
      return;
    }

    final completed = cleared.copyWith(isComplete: true);
    state = AsyncValue<MatchState>.data(completed);
    await _persistSnapshot(completed);
    await _completeGame(completed);
  }

  MatchState _nextBoardState(MatchState current) => current.copyWith(
    boardIndex: current.boardIndex + 1,
    completedPairCount:
        current.completedPairCount + current.game.correctPairs.length,
    game: _gameForBoard(current.cards, current.boardIndex + 1),
    selectedTermId: null,
    selectedDefinitionId: null,
    matchedPairIds: const <String>{},
    lastResult: null,
  );

  Future<void> _handleWrong(
    MatchState current,
    String termId,
    String definitionId,
  ) async {
    final result = MatchAttemptResult(
      outcome: MatchAttemptOutcome.wrong,
      termId: termId,
      definitionId: definitionId,
      sequence: ++_attemptSequence,
    );
    state = AsyncValue<MatchState>.data(
      current.copyWith(
        attemptCounts: {
          ...current.attemptCounts,
          termId: (current.attemptCounts[termId] ?? 0) + 1,
        },
        mistakes: current.mistakes + 1,
        comboCount: 0,
        lastResult: result,
      ),
    );
    await _persistSnapshot(state.requireValue);
    await Future<void>.delayed(DurationTokens.chartDraw);
    final latest = _stateValueOrNull(state);

    if (!_isCurrentAttempt(latest, result.sequence)) {
      return;
    }

    final updated = latest!.copyWith(
      selectedTermId: null,
      selectedDefinitionId: null,
      lastResult: null,
    );
    state = AsyncValue<MatchState>.data(updated);
    await _persistSnapshot(updated);
  }

  bool _isCurrentAttempt(MatchState? stateValue, int sequence) =>
      stateValue?.lastResult?.sequence == sequence;

  Future<void> _persistMatchReview(String termId, int attempts) async {
    final card = _cardsByTermId[termId];

    if (card == null) {
      return;
    }

    final review = ref
        .read(srsEngineProvider)
        .processMatchResult(card, attempts);
    final now = DateTime.now();
    await ref
        .read(flashcardRepositoryProvider)
        .save(
          card.copyWith(
            easeFactor: review.newEaseFactor,
            interval: review.newInterval,
            repetitions: review.newRepetitions,
            nextReviewDate: review.nextReviewDate,
            lastReviewedAt: now,
            updatedAt: now,
            status: review.newStatus,
          ),
        );
    final session = _session;

    if (session == null) {
      return;
    }

    await ref
        .read(cardReviewDaoProvider)
        .insertReview(
          CardReviewsTableCompanion.insert(
            cardId: card.id,
            sessionId: session.id,
            mode: StudyMode.match,
            rating: Value(_ratingIndexForAttempts(attempts)),
            isCorrect: true,
            reviewedAt: now,
          ),
        );
  }

  int _ratingIndexForAttempts(int attempts) => switch (attempts) {
    <= 1 => ReviewRating.easy.index,
    2 => ReviewRating.good.index,
    _ => ReviewRating.hard.index,
  };

  Future<void> _resolveSelection(MatchState current) async {
    final termId = current.selectedTermId;
    final definitionId = current.selectedDefinitionId;

    if (termId == null || definitionId == null) {
      return;
    }

    if (ref
        .read(matchEngineProvider(deckId))
        .checkMatch(termId, definitionId)) {
      await _handleCorrect(current, termId, definitionId);
      return;
    }

    await _handleWrong(current, termId, definitionId);
  }

  Future<MatchState> _startGame(int deckId) async {
    final loadedCards = await ref
        .read(getCardsByDeckUseCaseProvider)
        .call(deckId)
        .first;
    final cards = ref
        .read(matchEngineProvider(deckId))
        .shuffleCards(loadedCards);
    _cacheCards(cards);
    _attemptSequence = 0;

    if (cards.isEmpty) {
      _session = null;
      await _clearSnapshot();
      return MatchState(
        cards: const <FlashcardEntity>[],
        game: const (terms: [], definitions: [], correctPairs: {}),
        startTime: DateTime.now(),
      );
    }

    final game = _gameForBoard(cards, 0);
    _session = unwrapStudySessionResult(
      await ref
          .read(startStudySessionUseCaseProvider)
          .call(deckId: deckId, mode: StudyMode.match),
    );
    final nextState = MatchState(
      cards: cards,
      game: game,
      startTime: _session?.startedAt ?? DateTime.now(),
    );
    await _persistSnapshot(nextState);
    return nextState;
  }

  Future<void> _clearSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.clearIfMatches(deckId: deckId, mode: StudyMode.match);
  }

  Map<String, dynamic> _encodeState(MatchState current) => <String, dynamic>{
    'cards': current.cards.map((card) => card.toJson()).toList(growable: false),
    'game': <String, dynamic>{
      'terms': _encodeItems(current.game.terms),
      'definitions': _encodeItems(current.game.definitions),
      'correctPairs': current.game.correctPairs,
    },
    'startTime': current.startTime.toIso8601String(),
    'boardIndex': current.boardIndex,
    'completedPairCount': current.completedPairCount,
    'selectedTermId': current.selectedTermId,
    'selectedDefinitionId': current.selectedDefinitionId,
    'matchedPairIds': current.matchedPairIds.toList(growable: false),
    'attemptCounts': Map<String, int>.fromEntries(
      current.attemptCounts.entries.map(
        (entry) => MapEntry<String, int>(entry.key, entry.value),
      ),
    ),
    'mistakes': current.mistakes,
    'comboCount': current.comboCount,
  };

  Future<void> _persistSnapshot(MatchState current) async {
    if (current.isComplete) {
      await _clearSnapshot();
      return;
    }

    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.save(
      ActiveStudySessionSnapshot(
        deckId: deckId,
        mode: StudyMode.match,
        session: _session,
        modePlan: const <StudyMode>[StudyMode.match],
        modeState: current.modeState,
        allowedActions: current.allowedActions,
        currentItem: current.currentItemSnapshot,
        progress: current.progressSnapshot,
        sessionCompleted: current.isComplete,
        payload: _encodeState(current),
      ),
    );
  }

  Future<MatchState> _normalizeRestoredState(MatchState current) async {
    if (current.game.correctPairs.isEmpty) {
      return current;
    }

    if (current.matchedPairIds.length != current.game.correctPairs.length) {
      return current;
    }

    final cleared = current.copyWith(
      selectedTermId: null,
      selectedDefinitionId: null,
    );

    if (cleared.boardIndex < cleared.totalBoards - 1) {
      final nextState = _nextBoardState(cleared);
      await _persistSnapshot(nextState);
      return nextState;
    }

    final completed = cleared.copyWith(isComplete: true);
    await _completeGame(completed);
    return completed;
  }

  Future<MatchState?> _restoreSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    return store.restoreMatching(
      deckId: deckId,
      mode: StudyMode.match,
      decode: (snapshot) async {
        final storedCards = _decodeMatchCards(snapshot.payload['cards']);
        final cards = storedCards.isNotEmpty
            ? storedCards
            : await ref.read(getCardsByDeckUseCaseProvider).call(deckId).first;
        _cacheCards(cards);
        final boardIndex = _restoredBoardIndex(
          snapshot.payload['boardIndex'],
          cards.length,
        );
        final fallbackGame = _gameForBoard(cards, boardIndex);
        final decodedGame = _decodedGameOrFallback(
          raw: snapshot.payload['game'],
          fallback: fallbackGame,
        );
        final game =
            _isCompatibleMatchGame(
              decodedGame,
              fallbackGame.correctPairs.keys.toSet(),
            )
            ? decodedGame
            : fallbackGame;
        final validTermIds = game.terms.map((item) => item.id).toSet();
        final validDefinitionIds = game.definitions
            .map((item) => item.id)
            .toSet();
        final completedPairCount = _restoredCompletedPairCount(
          raw: snapshot.payload['completedPairCount'],
          boardIndex: boardIndex,
        );
        final restored = MatchState(
          cards: cards,
          game: game,
          startTime:
              DateTime.tryParse(
                snapshot.payload['startTime'] as String? ?? '',
              ) ??
              DateTime.now(),
          boardIndex: boardIndex,
          completedPairCount: completedPairCount,
          selectedTermId: _restoredSelectedMatchId(
            raw: snapshot.payload['selectedTermId'],
            validIds: validTermIds,
          ),
          selectedDefinitionId: _restoredSelectedMatchId(
            raw: snapshot.payload['selectedDefinitionId'],
            validIds: validDefinitionIds,
          ),
          matchedPairIds:
              (snapshot.payload['matchedPairIds'] as List<dynamic>? ??
                      const <dynamic>[])
                  .map((id) => id as String)
                  .where(validTermIds.contains)
                  .toSet(),
          attemptCounts:
              (snapshot.payload['attemptCounts'] as Map?) == null
                    ? const <String, int>{}
                    : (snapshot.payload['attemptCounts'] as Map).map(
                        (key, value) =>
                            MapEntry<String, int>(key as String, value as int),
                      )
                ..removeWhere((key, value) => !_cardsByTermId.containsKey(key)),
          mistakes: snapshot.payload['mistakes'] as int? ?? 0,
          comboCount: snapshot.payload['comboCount'] as int? ?? 0,
        );
        _attemptSequence = 0;
        _session = snapshot.session;
        return _normalizeRestoredState(restored);
      },
    );
  }

  void _cacheCards(List<FlashcardEntity> cards) {
    _cardsByTermId
      ..clear()
      ..addEntries(
        cards.map(
          (card) => MapEntry<String, FlashcardEntity>('term-${card.id}', card),
        ),
      );
  }

  ({
    List<({String id, String text, MatchItemType type})> terms,
    List<({String id, String text, MatchItemType type})> definitions,
    Map<String, String> correctPairs,
  })
  _gameForBoard(List<FlashcardEntity> cards, int boardIndex) {
    final start = boardIndex * MatchEngine.defaultPairsPerRound;
    final boardCards = cards
        .skip(start)
        .take(MatchEngine.defaultPairsPerRound)
        .toList(growable: false);
    return ref
        .read(matchEngineProvider(deckId))
        .generateGame(boardCards, pairsPerRound: boardCards.length);
  }
}

List<FlashcardEntity> _decodeMatchCards(Object? raw) =>
    (raw as List<dynamic>? ?? const <dynamic>[])
        .map(
          (card) =>
              FlashcardEntity.fromJson(Map<String, dynamic>.from(card as Map)),
        )
        .toList(growable: false);

({
  List<({String id, String text, MatchItemType type})> terms,
  List<({String id, String text, MatchItemType type})> definitions,
  Map<String, String> correctPairs,
})
_decodedGameOrFallback({
  required Object? raw,
  required ({
    List<({String id, String text, MatchItemType type})> terms,
    List<({String id, String text, MatchItemType type})> definitions,
    Map<String, String> correctPairs,
  })
  fallback,
}) {
  final decoded = _decodeGame(raw);

  if (decoded.correctPairs.isEmpty) {
    return fallback;
  }

  return decoded;
}

int _restoredBoardIndex(Object? raw, int cardCount) {
  if (cardCount == 0) {
    throw StateError('Match snapshot is missing cards.');
  }

  final boardCount = (cardCount / MatchEngine.defaultPairsPerRound).ceil();
  return clampSnapshotIndex(raw as int? ?? 0, boardCount);
}

int _restoredCompletedPairCount({
  required Object? raw,
  required int boardIndex,
}) {
  final count = raw as int? ?? 0;
  final maxCompletedPairCount = boardIndex * MatchEngine.defaultPairsPerRound;

  if (count < 0) {
    return 0;
  }

  if (count > maxCompletedPairCount) {
    return maxCompletedPairCount;
  }

  return count;
}

String? _restoredSelectedMatchId({
  required Object? raw,
  required Set<String> validIds,
}) {
  final value = raw as String?;

  if (value == null || validIds.contains(value)) {
    return value;
  }

  return null;
}

bool _isCompatibleMatchGame(
  ({
    List<({String id, String text, MatchItemType type})> terms,
    List<({String id, String text, MatchItemType type})> definitions,
    Map<String, String> correctPairs,
  })
  game,
  Set<String> validTermIds,
) {
  if (game.correctPairs.isEmpty) {
    return false;
  }

  return game.correctPairs.keys.toSet().containsAll(validTermIds) &&
      validTermIds.containsAll(game.correctPairs.keys);
}

List<Map<String, dynamic>> _encodeItems(
  List<({String id, String text, MatchItemType type})> items,
) => items
    .map(
      (item) => <String, dynamic>{
        'id': item.id,
        'text': item.text,
        'type': item.type.name,
      },
    )
    .toList(growable: false);

({
  List<({String id, String text, MatchItemType type})> terms,
  List<({String id, String text, MatchItemType type})> definitions,
  Map<String, String> correctPairs,
})
_decodeGame(Object? raw) {
  if (raw is! Map) {
    return (terms: const [], definitions: const [], correctPairs: const {});
  }

  final json = Map<String, dynamic>.from(raw);
  return (
    terms: _decodeItems(json['terms']),
    definitions: _decodeItems(json['definitions']),
    correctPairs: (json['correctPairs'] as Map?) == null
        ? const <String, String>{}
        : (json['correctPairs'] as Map).map(
            (key, value) =>
                MapEntry<String, String>(key as String, value as String),
          ),
  );
}

List<({String id, String text, MatchItemType type})> _decodeItems(Object? raw) {
  if (raw is! List) {
    return const [];
  }

  return raw
      .map(
        (item) => (
          id: (item as Map)['id'] as String? ?? '',
          text: item['text'] as String? ?? '',
          type: MatchItemType.values.byName(
            item['type'] as String? ?? MatchItemType.term.name,
          ),
        ),
      )
      .toList(growable: false);
}
