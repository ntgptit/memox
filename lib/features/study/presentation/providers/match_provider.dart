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
    required ({
      List<({String id, String text, MatchItemType type})> terms,
      List<({String id, String text, MatchItemType type})> definitions,
      Map<String, String> correctPairs,
    })
    game,
    required DateTime startTime,
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
  int get totalPairs => game.correctPairs.length;

  int get matchedCount => matchedPairIds.length;

  int get pairsLeft => totalPairs - matchedCount;

  bool isDefinitionMatched(String definitionId) {
    for (final termId in matchedPairIds) {
      if (game.correctPairs[termId] == definitionId) {
        return true;
      }
    }

    return false;
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

  Future<void> deselectItem() async {
    final current = _stateValueOrNull(state);

    if (current == null || current.lastResult != null || current.isComplete) {
      return;
    }

    final updated = current.copyWith(
      selectedTermId: null,
      selectedDefinitionId: null,
    );
    state = AsyncValue<MatchState>.data(updated);
    await _persistSnapshot(updated);
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
      if (current.selectedTermId == item.id) {
        final updated = current.copyWith(selectedTermId: null);
        state = AsyncValue<MatchState>.data(updated);
        await _persistSnapshot(updated);
        return;
      }

      final updated = current.copyWith(selectedTermId: item.id);
      state = AsyncValue<MatchState>.data(updated);
      await _persistSnapshot(updated);
      await _resolveSelection(updated);
      return;
    }

    if (current.selectedDefinitionId == item.id) {
      final updated = current.copyWith(selectedDefinitionId: null);
      state = AsyncValue<MatchState>.data(updated);
      await _persistSnapshot(updated);
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
    _session = await ref
        .read(completeStudySessionUseCaseProvider)
        .call(completedSession);
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

    final cleared = latest!.copyWith(
      selectedTermId: null,
      selectedDefinitionId: null,
      lastResult: null,
      isComplete: matchedPairIds.length == latest.totalPairs,
    );
    state = AsyncValue<MatchState>.data(cleared);
    await _persistSnapshot(cleared);

    if (!cleared.isComplete) {
      return;
    }

    await _completeGame(cleared);
  }

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
    final cards = await ref
        .read(getCardsByDeckUseCaseProvider)
        .call(deckId)
        .first;
    final game = ref.read(matchEngineProvider(deckId)).generateGame(cards);
    _cardsByTermId
      ..clear()
      ..addEntries(
        cards.map(
          (card) => MapEntry<String, FlashcardEntity>('term-${card.id}', card),
        ),
      );
    _attemptSequence = 0;

    if (game.correctPairs.isEmpty) {
      _session = null;
      await _clearSnapshot();
      return MatchState(game: game, startTime: DateTime.now());
    }

    _session = await ref
        .read(startStudySessionUseCaseProvider)
        .call(deckId: deckId, mode: StudyMode.match);
    final nextState = MatchState(
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
    'game': <String, dynamic>{
      'terms': _encodeItems(current.game.terms),
      'definitions': _encodeItems(current.game.definitions),
      'correctPairs': current.game.correctPairs,
    },
    'startTime': current.startTime.toIso8601String(),
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
        payload: _encodeState(current),
      ),
    );
  }

  Future<MatchState?> _restoreSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    final snapshot = store.load();

    if (snapshot == null) {
      return null;
    }

    if (snapshot.deckId != deckId || snapshot.mode != StudyMode.match) {
      return null;
    }

    final cards = await ref
        .read(getCardsByDeckUseCaseProvider)
        .call(deckId)
        .first;
    _cardsByTermId
      ..clear()
      ..addEntries(
        cards.map(
          (card) => MapEntry<String, FlashcardEntity>('term-${card.id}', card),
        ),
      );
    _attemptSequence = 0;
    _session = snapshot.session;
    return MatchState(
      game: _decodeGame(snapshot.payload['game']),
      startTime:
          DateTime.tryParse(snapshot.payload['startTime'] as String? ?? '') ??
          DateTime.now(),
      selectedTermId: snapshot.payload['selectedTermId'] as String?,
      selectedDefinitionId: snapshot.payload['selectedDefinitionId'] as String?,
      matchedPairIds:
          (snapshot.payload['matchedPairIds'] as List<dynamic>? ??
                  const <dynamic>[])
              .map((id) => id as String)
              .toSet(),
      attemptCounts: (snapshot.payload['attemptCounts'] as Map?) == null
          ? const <String, int>{}
          : (snapshot.payload['attemptCounts'] as Map).map(
              (key, value) =>
                  MapEntry<String, int>(key as String, value as int),
            ),
      mistakes: snapshot.payload['mistakes'] as int? ?? 0,
      comboCount: snapshot.payload['comboCount'] as int? ?? 0,
    );
  }
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
