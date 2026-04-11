import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
import 'package:memox/features/study/presentation/support/study_restore_utils.dart';
import 'package:memox/features/study/presentation/support/study_session_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recall_provider.freezed.dart';
part 'recall_provider.g.dart';

typedef RecallResult = ({int cardId, String userAnswer, SelfRating rating});

@freezed
abstract class RecallState with _$RecallState {
  const factory RecallState({
    required List<FlashcardEntity> cards,
    required int currentIndex,
    required String userAnswer,
    @Default(false) bool isRevealed,
    SelfRating? selfRating,
    @Default(<RecallResult>[]) List<RecallResult> results,
    @Default(<int>{}) Set<int> retryPendingCardIds,
    @Default(<int, int>{}) Map<int, int> attemptCounts,
    @Default(false) bool isComplete,
  }) = _RecallState;
}

extension RecallStateX on RecallState {
  int get totalCards => cards.length;

  int get displayIndex {
    if (totalCards == 0) {
      return 0;
    }

    final nextIndex = resolvedCount + 1;
    return nextIndex > totalCards ? totalCards : nextIndex;
  }

  bool get canReveal => currentCard != null && !isRevealed;

  FlashcardEntity? get currentCard {
    if (cards.isEmpty || isComplete) {
      return null;
    }

    return cards[currentIndex];
  }

  List<StudySessionAllowedAction> get allowedActions {
    final card = currentCard;

    if (card == null || isComplete) {
      return const <StudySessionAllowedAction>[];
    }

    if (selfRating != null) {
      return const <StudySessionAllowedAction>[
        StudySessionAllowedAction.goNext,
      ];
    }

    if (isRevealed) {
      return const <StudySessionAllowedAction>[
        StudySessionAllowedAction.markRemembered,
        StudySessionAllowedAction.retryItem,
      ];
    }

    return const <StudySessionAllowedAction>[
      StudySessionAllowedAction.revealAnswer,
      StudySessionAllowedAction.retryItem,
    ];
  }

  ActiveStudySessionCurrentItem? get currentItemSnapshot {
    final card = currentCard;

    if (card == null) {
      return null;
    }

    return ActiveStudySessionCurrentItem(
      cardId: card.id,
      position: displayIndex,
    );
  }

  int get gotItCount =>
      results.where((result) => result.rating == SelfRating.gotIt).length;

  int get partialCount =>
      results.where((result) => result.rating == SelfRating.partial).length;

  int get missedCount =>
      results.where((result) => result.rating == SelfRating.missed).length;

  int get resolvedCount {
    final completedCount = results.length - retryPendingCardIds.length;

    if (completedCount < 0) {
      return 0;
    }

    return completedCount;
  }

  StudySessionModeState get modeState {
    if (isComplete) {
      return StudySessionModeState.completed;
    }

    if (selfRating != null || isRevealed) {
      return StudySessionModeState.waitingFeedback;
    }

    if (currentCard != null && retryPendingCardIds.contains(currentCard!.id)) {
      return StudySessionModeState.retryPending;
    }

    if (currentIndex == 0 && results.isEmpty && userAnswer.isEmpty) {
      return StudySessionModeState.initialized;
    }

    return StudySessionModeState.inProgress;
  }

  ActiveStudySessionProgress get progressSnapshot => ActiveStudySessionProgress(
    completedCount: resolvedCount,
    totalCount: totalCards,
  );
}

RecallState? _stateValueOrNull(AsyncValue<RecallState> value) =>
    switch (value) {
      AsyncData<RecallState>(:final value) => value,
      _ => null,
    };

@riverpod
math.Random recallRandom(Ref ref, int deckId) => math.Random();

@riverpod
Duration recallAdvanceDelay(Ref ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return settings?.autoAdvanceDuration ??
      AppSettings.defaults.autoAdvanceDuration;
}

@Riverpod(keepAlive: true)
class RecallSession extends _$RecallSession {
  StudySession? _session;
  var _interactionSequence = 0;

  @override
  Future<RecallState> build(int deckId) async {
    final restored = await _restoreSnapshot();

    if (restored != null) {
      return restored;
    }

    return _startSession(deckId);
  }

  Future<void> revealAnswer() async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete || current.isRevealed) {
      return;
    }

    if (!current.canReveal) {
      return;
    }

    final updated = current.copyWith(isRevealed: true);
    state = AsyncValue<RecallState>.data(updated);
    await _persistSnapshot(updated);
  }

  Future<void> markMissed() async {
    final current = _stateValueOrNull(state);
    final card = current?.currentCard;

    if (current == null || card == null || current.isComplete) {
      return;
    }

    if (current.isRevealed || current.selfRating != null) {
      return;
    }

    final updated = _applyRating(
      current,
      cardId: card.id,
      userAnswer: current.userAnswer,
      rating: SelfRating.missed,
    );
    final sequence = ++_interactionSequence;
    state = AsyncValue<RecallState>.data(updated);
    await _persistSnapshot(updated);
    await _persistRecallReview(card, current.userAnswer, SelfRating.missed);
    await Future<void>.delayed(ref.read(recallAdvanceDelayProvider));
    final latest = _stateValueOrNull(state);

    if (!_shouldAdvance(latest, sequence, card.id)) {
      return;
    }

    await _advance(latest!);
  }

  Future<void> rateSelf(SelfRating rating) async {
    final current = _stateValueOrNull(state);
    final card = current?.currentCard;

    if (current == null || card == null || current.isComplete) {
      return;
    }

    if (!current.isRevealed || current.selfRating != null) {
      return;
    }

    final updated = _applyRating(
      current,
      cardId: card.id,
      userAnswer: current.userAnswer,
      rating: rating,
    );
    final sequence = ++_interactionSequence;
    state = AsyncValue<RecallState>.data(updated);
    await _persistSnapshot(updated);
    await _persistRecallReview(card, current.userAnswer, rating);
    await Future<void>.delayed(ref.read(recallAdvanceDelayProvider));
    final latest = _stateValueOrNull(state);

    if (!_shouldAdvance(latest, sequence, card.id)) {
      return;
    }

    await _advance(latest!);
  }

  Future<void> startSession() async {
    _interactionSequence++;
    state = const AsyncValue<RecallState>.loading();
    final nextState = await _startSession(deckId);
    state = AsyncValue<RecallState>.data(nextState);
  }

  Future<void> updateAnswer(String text) async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete || current.isRevealed) {
      return;
    }

    if (text == current.userAnswer) {
      return;
    }

    final updated = current.copyWith(userAnswer: text);
    state = AsyncValue<RecallState>.data(updated);
    await _persistSnapshot(updated);
  }

  Future<void> _advance(RecallState current) async {
    final nextIndex = _nextIndex(current);

    if (nextIndex == null) {
      final completed = current.copyWith(isComplete: true);
      state = AsyncValue<RecallState>.data(completed);
      await _completeSession(completed);
      return;
    }

    final updated = current.copyWith(
      currentIndex: nextIndex,
      userAnswer: '',
      isRevealed: false,
      selfRating: null,
    );
    state = AsyncValue<RecallState>.data(updated);
    await _persistSnapshot(updated);
  }

  Future<void> _completeSession(RecallState current) async {
    final session = _session;

    if (session == null) {
      await _clearSnapshot();
      return;
    }

    final startedAt = session.startedAt ?? DateTime.now();
    final gotItCount = current.gotItCount;
    final completedSession = session.copyWith(
      completedAt: DateTime.now(),
      totalCards: current.totalCards,
      correctCount: gotItCount,
      wrongCount: current.totalCards - gotItCount,
      durationSeconds: DateTime.now().difference(startedAt).inSeconds,
    );
    _session = unwrapStudySessionResult(
      await ref
          .read(completeStudySessionUseCaseProvider)
          .call(completedSession),
    );
    await _clearSnapshot();
  }

  Future<void> _persistRecallReview(
    FlashcardEntity card,
    String userAnswer,
    SelfRating rating,
  ) async {
    final review = ref
        .read(srsEngineProvider)
        .processRecallSelfRating(card, rating);
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
            mode: StudyMode.recall,
            rating: Value(_reviewRatingIndex(rating)),
            selfRating: Value(rating.index),
            isCorrect: rating == SelfRating.gotIt,
            userAnswer: Value(userAnswer),
            reviewedAt: now,
          ),
        );
  }

  int _reviewRatingIndex(SelfRating rating) => switch (rating) {
    SelfRating.missed => ReviewRating.again.index,
    SelfRating.partial => ReviewRating.hard.index,
    SelfRating.gotIt => ReviewRating.good.index,
  };

  List<FlashcardEntity> _shuffleCards(List<FlashcardEntity> cards) {
    final shuffled = [...cards]
      ..shuffle(ref.read(recallRandomProvider(deckId)));
    return shuffled;
  }

  RecallState _applyRating(
    RecallState current, {
    required int cardId,
    required String userAnswer,
    required SelfRating rating,
  }) {
    final nextAttemptCounts = {
      ...current.attemptCounts,
      cardId: (current.attemptCounts[cardId] ?? 0) + 1,
    };
    final nextRetryPendingCardIds = {...current.retryPendingCardIds};
    final isRetryRound = current.retryPendingCardIds.contains(cardId);

    if (rating == SelfRating.missed && !isRetryRound) {
      nextRetryPendingCardIds.add(cardId);
    }

    if (rating != SelfRating.missed || isRetryRound) {
      nextRetryPendingCardIds.remove(cardId);
    }

    return current.copyWith(
      selfRating: rating,
      results: _upsertResult(current.results, (
        cardId: cardId,
        userAnswer: userAnswer,
        rating: rating,
      )),
      retryPendingCardIds: nextRetryPendingCardIds,
      attemptCounts: nextAttemptCounts,
    );
  }

  int? _nextIndex(RecallState current) {
    if (current.cards.isEmpty) {
      return null;
    }

    final unresolved = _unresolvedCardIds(current);

    if (unresolved.isEmpty) {
      return null;
    }

    for (
      var index = current.currentIndex + 1;
      index < current.cards.length;
      index++
    ) {
      if (unresolved.contains(current.cards[index].id)) {
        return index;
      }
    }

    for (var index = 0; index < current.cards.length; index++) {
      if (unresolved.contains(current.cards[index].id)) {
        return index;
      }
    }

    return null;
  }

  Set<int> _unresolvedCardIds(RecallState current) {
    final resolvedCardIds = current.results
        .map((result) => result.cardId)
        .toSet();
    return current.cards
        .where(
          (card) =>
              !resolvedCardIds.contains(card.id) ||
              current.retryPendingCardIds.contains(card.id),
        )
        .map((card) => card.id)
        .toSet();
  }

  bool _shouldAdvance(RecallState? stateValue, int sequence, int cardId) {
    if (stateValue == null || _interactionSequence != sequence) {
      return false;
    }

    final currentCard = stateValue.currentCard;

    if (currentCard == null) {
      return false;
    }

    return stateValue.selfRating != null && currentCard.id == cardId;
  }

  Future<RecallState> _startSession(int deckId) async {
    final loadedCards = await ref
        .read(getCardsByDeckUseCaseProvider)
        .call(deckId)
        .first;
    final cards = _shuffleCards(loadedCards);
    _interactionSequence = 0;

    if (cards.isEmpty) {
      _session = null;
      await _clearSnapshot();
      return const RecallState(
        cards: <FlashcardEntity>[],
        currentIndex: 0,
        userAnswer: '',
      );
    }

    _session = unwrapStudySessionResult(
      await ref
          .read(startStudySessionUseCaseProvider)
          .call(deckId: cards.first.deckId, mode: StudyMode.recall),
    );
    final nextState = RecallState(
      cards: cards,
      currentIndex: 0,
      userAnswer: '',
    );
    await _persistSnapshot(nextState);
    return nextState;
  }

  Future<void> _clearSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.clearIfMatches(deckId: deckId, mode: StudyMode.recall);
  }

  Map<String, dynamic> _encodeState(RecallState current) => <String, dynamic>{
    'cards': current.cards.map((card) => card.toJson()).toList(growable: false),
    'currentIndex': current.currentIndex,
    'userAnswer': current.userAnswer,
    'isRevealed': current.isRevealed,
    'selfRating': current.selfRating?.name,
    'results': current.results
        .map(
          (result) => <String, dynamic>{
            'cardId': result.cardId,
            'userAnswer': result.userAnswer,
            'rating': result.rating.name,
          },
        )
        .toList(growable: false),
    'retryPendingCardIds': current.retryPendingCardIds.toList(growable: false),
    'attemptCounts': current.attemptCounts.map(
      (key, value) => MapEntry<String, int>('$key', value),
    ),
  };

  Future<void> _persistSnapshot(RecallState current) async {
    if (current.cards.isEmpty || current.isComplete) {
      await _clearSnapshot();
      return;
    }

    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.save(
      ActiveStudySessionSnapshot(
        deckId: deckId,
        mode: StudyMode.recall,
        session: _session,
        modePlan: const <StudyMode>[StudyMode.recall],
        modeState: current.modeState,
        allowedActions: current.allowedActions,
        currentItem: current.currentItemSnapshot,
        progress: current.progressSnapshot,
        sessionCompleted: current.isComplete,
        payload: _encodeState(current),
      ),
    );
  }

  Future<RecallState> _normalizeRestoredState(RecallState current) async {
    if (current.selfRating == null) {
      return current;
    }

    final nextIndex = _nextIndex(current);

    if (nextIndex == null) {
      final completed = current.copyWith(isComplete: true);
      await _completeSession(completed);
      return completed;
    }

    final updated = current.copyWith(
      currentIndex: nextIndex,
      userAnswer: '',
      isRevealed: false,
      selfRating: null,
    );
    await _persistSnapshot(updated);
    return updated;
  }

  Future<RecallState?> _restoreSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    return store.restoreMatching(
      deckId: deckId,
      mode: StudyMode.recall,
      decode: (snapshot) async {
        final cards = _decodeRecallCards(snapshot.payload['cards']);
        final requestedIndex = snapshot.payload['currentIndex'] as int? ?? 0;
        final currentIndex = _restoredRecallIndex(
          snapshot.payload['currentIndex'],
          cards.length,
        );
        final keepsCurrentCardState = requestedIndex == currentIndex;
        final cardIds = cards.map((card) => card.id).toSet();
        final restored = RecallState(
          cards: cards,
          currentIndex: currentIndex,
          userAnswer: keepsCurrentCardState
              ? snapshot.payload['userAnswer'] as String? ?? ''
              : '',
          isRevealed:
              keepsCurrentCardState &&
              (snapshot.payload['isRevealed'] as bool? ?? false),
          selfRating: !keepsCurrentCardState
              ? null
              : snapshot.payload['selfRating'] == null
              ? null
              : SelfRating.values.byName(
                  snapshot.payload['selfRating'] as String,
                ),
          results:
              (snapshot.payload['results'] as List<dynamic>? ??
                      const <dynamic>[])
                  .map(
                    (result) => (
                      cardId: (result as Map)['cardId'] as int,
                      userAnswer: result['userAnswer'] as String? ?? '',
                      rating: SelfRating.values.byName(
                        result['rating'] as String? ?? SelfRating.missed.name,
                      ),
                    ),
                  )
                  .where((result) => cardIds.contains(result.cardId))
                  .toList(growable: false),
          retryPendingCardIds:
              (snapshot.payload['retryPendingCardIds'] as List<dynamic>? ??
                      const <dynamic>[])
                  .map((cardId) => cardId as int)
                  .where(cardIds.contains)
                  .toSet(),
          attemptCounts:
              (snapshot.payload['attemptCounts'] as Map?) == null
                    ? const <int, int>{}
                    : (snapshot.payload['attemptCounts'] as Map).map(
                        (key, value) => MapEntry<int, int>(
                          int.parse(key as String),
                          value as int,
                        ),
                      )
                ..removeWhere((key, value) => !cardIds.contains(key)),
        );
        _interactionSequence = 0;
        _session = snapshot.session;
        return _normalizeRestoredState(restored);
      },
    );
  }
}

List<FlashcardEntity> _decodeRecallCards(Object? raw) =>
    (raw as List<dynamic>? ?? const <dynamic>[])
        .map(
          (card) =>
              FlashcardEntity.fromJson(Map<String, dynamic>.from(card as Map)),
        )
        .toList(growable: false);

int _restoredRecallIndex(Object? raw, int cardCount) {
  if (cardCount == 0) {
    throw StateError('Recall snapshot is missing cards.');
  }

  return clampSnapshotIndex(raw as int? ?? 0, cardCount);
}

List<RecallResult> _upsertResult(
  List<RecallResult> results,
  RecallResult next,
) => <RecallResult>[
  for (final result in results)
    if (result.cardId != next.cardId) result,
  next,
];
