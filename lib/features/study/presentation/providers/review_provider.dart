import 'package:drift/drift.dart' show Value;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/support/flashcard_flags.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
import 'package:memox/features/study/presentation/support/study_restore_utils.dart';
import 'package:memox/features/study/presentation/support/study_session_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_provider.freezed.dart';
part 'review_provider.g.dart';

const int _reviewSessionCardLimit = 500;

typedef ReviewResult = ({int cardId, ReviewRating rating});

@freezed
abstract class ReviewState with _$ReviewState {
  const factory ReviewState({
    required List<FlashcardEntity> cards,
    required int currentIndex,
    required Map<ReviewRating, String> nextReviewTimes,
    @Default(false) bool isFlipped,
    ReviewRating? selectedRating,
    @Default(<ReviewResult>[]) List<ReviewResult> results,
    @Default(<int>{}) Set<int> retryPendingCardIds,
    @Default(false) bool isComplete,
  }) = _ReviewState;
}

extension ReviewStateX on ReviewState {
  int get againCount => _countByRating(ReviewRating.again);

  int get displayIndex => totalCards == 0 ? 0 : currentIndex + 1;

  int get easyCount => _countByRating(ReviewRating.easy);

  int get goodCount => _countByRating(ReviewRating.good);

  int get hardCount => _countByRating(ReviewRating.hard);

  bool get isCurrentCardPendingRetry {
    final card = currentCard;

    if (card == null) {
      return false;
    }

    return retryPendingCardIds.contains(card.id);
  }

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

    if (!isFlipped) {
      return const <StudySessionAllowedAction>[
        StudySessionAllowedAction.revealAnswer,
      ];
    }

    if (selectedRating == null) {
      return const <StudySessionAllowedAction>[
        StudySessionAllowedAction.markRemembered,
        StudySessionAllowedAction.retryItem,
      ];
    }

    return const <StudySessionAllowedAction>[StudySessionAllowedAction.goNext];
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

  StudySessionModeState get modeState {
    if (isComplete) {
      return StudySessionModeState.completed;
    }

    if (isCurrentCardPendingRetry) {
      return StudySessionModeState.retryPending;
    }

    if (isFlipped || selectedRating != null) {
      return StudySessionModeState.waitingFeedback;
    }

    if (currentIndex == 0 && results.isEmpty) {
      return StudySessionModeState.initialized;
    }

    return StudySessionModeState.inProgress;
  }

  ActiveStudySessionProgress get progressSnapshot => ActiveStudySessionProgress(
    completedCount: results.length,
    totalCount: totalCards,
  );

  int get successfulCount => totalCards - againCount;

  int get totalCards => cards.length;

  int _countByRating(ReviewRating rating) =>
      results.where((result) => result.rating == rating).length;
}

ReviewState? _stateValueOrNull(AsyncValue<ReviewState> value) =>
    switch (value) {
      AsyncData<ReviewState>(:final value) => value,
      _ => null,
    };

@Riverpod(keepAlive: true)
class ReviewSession extends _$ReviewSession {
  StudySession? _session;

  @override
  Future<ReviewState> build(int deckId) async {
    final restored = await _restoreSnapshot();

    if (restored != null) {
      return restored;
    }

    return _startSession(deckId);
  }

  Future<void> rate(ReviewRating rating) async {
    final current = _stateValueOrNull(state);
    final card = current?.currentCard;

    if (current == null || card == null || current.isComplete) {
      return;
    }

    if (!current.isFlipped || current.selectedRating != null) {
      return;
    }

    final updated = current.copyWith(selectedRating: rating);
    state = AsyncValue<ReviewState>.data(updated);
    await _persistReview(card, rating);
    await _advance(updated, card.id, rating);
  }

  Future<void> toggleFlip() async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete) {
      return;
    }

    final updated = current.copyWith(isFlipped: !current.isFlipped);
    state = AsyncValue<ReviewState>.data(updated);
    await _persistSnapshot(updated);
  }

  Future<void> startSession() async {
    state = const AsyncValue<ReviewState>.loading();
    final nextState = await _startSession(deckId);
    state = AsyncValue<ReviewState>.data(nextState);
  }

  Future<void> _advance(
    ReviewState current,
    int cardId,
    ReviewRating rating,
  ) async {
    final shouldQueueRetry =
        rating == ReviewRating.again &&
        !current.retryPendingCardIds.contains(cardId);

    if (shouldQueueRetry) {
      final reorderedCards = [...current.cards];
      final retryCard = reorderedCards.removeAt(current.currentIndex);
      reorderedCards.add(retryCard);
      final nextRetryPendingCardIds = {...current.retryPendingCardIds, cardId};
      final nextIndex = _nextIndexAfterRetry(
        currentIndex: current.currentIndex,
        cards: reorderedCards,
        retryPendingCardIds: nextRetryPendingCardIds,
      );
      final queued = current.copyWith(
        cards: reorderedCards,
        currentIndex: nextIndex,
        nextReviewTimes: _nextReviewTimes(reorderedCards[nextIndex]),
        isFlipped: false,
        selectedRating: null,
        retryPendingCardIds: nextRetryPendingCardIds,
      );
      state = AsyncValue<ReviewState>.data(queued);
      await _persistSnapshot(queued);
      return;
    }

    final nextResults = <ReviewResult>[
      ...current.results,
      (cardId: cardId, rating: rating),
    ];
    final nextRetryPendingCardIds = current.retryPendingCardIds
        .where((pendingCardId) => pendingCardId != cardId)
        .toSet();

    if (current.currentIndex == current.cards.length - 1) {
      final completed = current.copyWith(
        results: nextResults,
        retryPendingCardIds: nextRetryPendingCardIds,
        isComplete: true,
      );
      state = AsyncValue<ReviewState>.data(completed);
      await _completeSession(completed);
      return;
    }

    final nextIndex = current.currentIndex + 1;
    final nextCard = current.cards[nextIndex];
    final updated = current.copyWith(
      currentIndex: nextIndex,
      nextReviewTimes: _nextReviewTimes(nextCard),
      isFlipped: false,
      selectedRating: null,
      results: nextResults,
      retryPendingCardIds: nextRetryPendingCardIds,
    );
    state = AsyncValue<ReviewState>.data(updated);
    await _persistSnapshot(updated);
  }

  Future<void> _completeSession(ReviewState current) async {
    final session = _session;

    if (session == null) {
      return;
    }

    final now = DateTime.now();
    final startedAt = session.startedAt ?? now;
    final completedSession = session.copyWith(
      completedAt: now,
      totalCards: current.totalCards,
      correctCount: current.successfulCount,
      wrongCount: current.againCount,
      durationSeconds: now.difference(startedAt).inSeconds,
    );
    _session = unwrapStudySessionResult(
      await ref
          .read(completeStudySessionUseCaseProvider)
          .call(completedSession),
    );
    await _clearSnapshot();
  }

  Map<ReviewRating, String> _nextReviewTimes(FlashcardEntity card) =>
      ref.read(srsEngineProvider).getNextReviewTimes(card);

  Future<int> _persistReview(FlashcardEntity card, ReviewRating rating) async {
    final review = ref.read(srsEngineProvider).processReview(card, rating);
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
      return 0;
    }

    return ref
        .read(cardReviewDaoProvider)
        .insertReview(
          CardReviewsTableCompanion.insert(
            cardId: card.id,
            sessionId: session.id,
            mode: StudyMode.review,
            rating: Value(rating.index),
            isCorrect: rating != ReviewRating.again,
            reviewedAt: now,
          ),
        );
  }

  Future<bool?> toggleFlag() async {
    final current = _stateValueOrNull(state);
    final card = current?.currentCard;

    if (current == null || card == null || current.isComplete) {
      return null;
    }

    final nextCard = card.copyWithFlagged(isFlagged: !card.isFlagged);
    await ref.read(flashcardRepositoryProvider).save(nextCard);
    final nextCards = [...current.cards];
    nextCards[current.currentIndex] = nextCard;
    final updated = current.copyWith(cards: nextCards);
    state = AsyncValue<ReviewState>.data(updated);
    await _persistSnapshot(updated);
    return nextCard.isFlagged;
  }

  Future<ReviewState> _startSession(int deckId) async {
    final cards = await ref
        .read(getDueCardsUseCaseProvider)
        .call(deckId: deckId, limit: _reviewSessionCardLimit);

    if (cards.isEmpty) {
      _session = null;
      await _clearSnapshot();
      return const ReviewState(
        cards: <FlashcardEntity>[],
        currentIndex: 0,
        nextReviewTimes: <ReviewRating, String>{},
      );
    }

    _session = unwrapStudySessionResult(
      await ref.read(startStudySessionUseCaseProvider).call(deckId: deckId),
    );
    final nextState = ReviewState(
      cards: cards,
      currentIndex: 0,
      nextReviewTimes: _nextReviewTimes(cards.first),
    );
    await _persistSnapshot(nextState);
    return nextState;
  }

  Future<void> _clearSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.clearIfMatches(deckId: deckId, mode: StudyMode.review);
  }

  Map<String, dynamic> _encodeState(ReviewState current) => <String, dynamic>{
    'cards': current.cards.map((card) => card.toJson()).toList(growable: false),
    'currentIndex': current.currentIndex,
    'nextReviewTimes': current.nextReviewTimes.map(
      (key, value) => MapEntry<String, String>(key.name, value),
    ),
    'isFlipped': current.isFlipped,
    'results': current.results
        .map(
          (result) => <String, dynamic>{
            'cardId': result.cardId,
            'rating': result.rating.name,
          },
        )
        .toList(growable: false),
    'retryPendingCardIds': current.retryPendingCardIds.toList(growable: false),
  };

  Future<void> _persistSnapshot(ReviewState current) async {
    if (current.cards.isEmpty || current.isComplete) {
      await _clearSnapshot();
      return;
    }

    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.save(
      ActiveStudySessionSnapshot(
        deckId: deckId,
        mode: StudyMode.review,
        session: _session,
        modePlan: const <StudyMode>[StudyMode.review],
        modeState: current.modeState,
        allowedActions: current.allowedActions,
        currentItem: current.currentItemSnapshot,
        progress: current.progressSnapshot,
        sessionCompleted: current.isComplete,
        payload: _encodeState(current),
      ),
    );
  }

  Future<ReviewState?> _restoreSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    return store.restoreMatching(
      deckId: deckId,
      mode: StudyMode.review,
      decode: (snapshot) {
        final cards = _decodeReviewCards(snapshot.payload['cards']);
        final requestedIndex = snapshot.payload['currentIndex'] as int? ?? 0;
        final currentIndex = _restoredReviewIndex(
          snapshot.payload['currentIndex'],
          cards.length,
        );
        final cardIds = cards.map((card) => card.id).toSet();
        final results =
            (snapshot.payload['results'] as List<dynamic>? ?? const <dynamic>[])
                .map((result) {
                  final resultJson = Map<String, dynamic>.from(
                    result as Map<Object?, Object?>,
                  );
                  return (
                    cardId: resultJson['cardId'] as int,
                    rating: ReviewRating.values.byName(
                      resultJson['rating'] as String,
                    ),
                  );
                })
                .where((result) => cardIds.contains(result.cardId))
                .toList(growable: false);
        final retryPendingCardIds =
            (snapshot.payload['retryPendingCardIds'] as List<dynamic>? ??
                    const <dynamic>[])
                .map((cardId) => cardId as int)
                .where(cardIds.contains)
                .toSet();
        final restored = ReviewState(
          cards: cards,
          currentIndex: currentIndex,
          nextReviewTimes: _nextReviewTimes(cards[currentIndex]),
          isFlipped:
              requestedIndex == currentIndex &&
              (snapshot.payload['isFlipped'] as bool? ?? false),
          results: results,
          retryPendingCardIds: retryPendingCardIds,
        );
        _session = snapshot.session;
        return restored;
      },
    );
  }
}

List<FlashcardEntity> _decodeReviewCards(Object? raw) =>
    (raw as List<dynamic>? ?? const <dynamic>[])
        .map(
          (card) =>
              FlashcardEntity.fromJson(Map<String, dynamic>.from(card as Map)),
        )
        .toList(growable: false);

int _restoredReviewIndex(Object? raw, int cardCount) {
  if (cardCount == 0) {
    throw StateError('Review snapshot is missing cards.');
  }

  return clampSnapshotIndex(raw as int? ?? 0, cardCount);
}

int _nextIndexAfterRetry({
  required int currentIndex,
  required List<FlashcardEntity> cards,
  required Set<int> retryPendingCardIds,
}) {
  if (cards.isEmpty) {
    return 0;
  }

  if (currentIndex < cards.length) {
    if (currentIndex < cards.length - 1) {
      return currentIndex;
    }

    final retryIndex = cards.indexWhere(
      (card) => retryPendingCardIds.contains(card.id),
    );

    if (retryIndex >= 0) {
      return retryIndex;
    }

    return currentIndex;
  }

  return cards.length - 1;
}
