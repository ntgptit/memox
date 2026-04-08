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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_provider.freezed.dart';
part 'review_provider.g.dart';

const int _reviewSessionCardLimit = 500;

typedef ReviewResult = ({int cardId, ReviewRating rating});
typedef ReviewUndoAction = ({
  FlashcardEntity previousCard,
  ReviewState previousState,
  StudySession? previousSession,
  int reviewId,
});

@freezed
abstract class ReviewState with _$ReviewState {
  const factory ReviewState({
    required List<FlashcardEntity> cards,
    required int currentIndex,
    required Map<ReviewRating, String> nextReviewTimes,
    @Default(false) bool isFlipped,
    ReviewRating? selectedRating,
    @Default(<ReviewResult>[]) List<ReviewResult> results,
    @Default(0) int lastActionSequence,
    ReviewRating? lastRated,
    @Default(false) bool isComplete,
  }) = _ReviewState;
}

extension ReviewStateX on ReviewState {
  int get againCount => _countByRating(ReviewRating.again);

  int get displayIndex => totalCards == 0 ? 0 : currentIndex + 1;

  int get easyCount => _countByRating(ReviewRating.easy);

  int get goodCount => _countByRating(ReviewRating.good);

  int get hardCount => _countByRating(ReviewRating.hard);

  FlashcardEntity? get currentCard {
    if (cards.isEmpty || isComplete) {
      return null;
    }

    return cards[currentIndex];
  }

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
  ReviewUndoAction? _pendingUndo;

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
    final reviewId = await _persistReview(card, rating);
    await _advance(
      updated,
      card.id,
      rating,
      reviewId: reviewId,
      previousCard: card,
      previousState: current,
      previousSession: _session,
    );
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
    _pendingUndo = null;
    state = const AsyncValue<ReviewState>.loading();
    final nextState = await _startSession(deckId);
    state = AsyncValue<ReviewState>.data(nextState);
  }

  Future<void> _advance(
    ReviewState current,
    int cardId,
    ReviewRating rating, {
    required int reviewId,
    required FlashcardEntity previousCard,
    required ReviewState previousState,
    required StudySession? previousSession,
  }) async {
    final nextResults = <ReviewResult>[
      ...current.results,
      (cardId: cardId, rating: rating),
    ];
    final nextSequence = current.lastActionSequence + 1;

    if (current.currentIndex == current.cards.length - 1) {
      final completed = current.copyWith(
        results: nextResults,
        lastActionSequence: nextSequence,
        lastRated: rating,
        isComplete: true,
      );
      state = AsyncValue<ReviewState>.data(completed);
      await _completeSession(completed);
      _pendingUndo = (
        previousCard: previousCard,
        previousState: previousState,
        previousSession: previousSession,
        reviewId: reviewId,
      );
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
      lastActionSequence: nextSequence,
      lastRated: rating,
    );
    state = AsyncValue<ReviewState>.data(updated);
    _pendingUndo = (
      previousCard: previousCard,
      previousState: previousState,
      previousSession: previousSession,
      reviewId: reviewId,
    );
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
    _session = await ref
        .read(completeStudySessionUseCaseProvider)
        .call(completedSession);
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

  Future<bool> undoLastRating() async {
    final pendingUndo = _pendingUndo;

    if (pendingUndo == null) {
      return false;
    }

    _pendingUndo = null;
    await ref.read(flashcardRepositoryProvider).save(pendingUndo.previousCard);

    if (pendingUndo.reviewId > 0) {
      await ref.read(cardReviewDaoProvider).deleteById(pendingUndo.reviewId);
    }

    final previousSession = pendingUndo.previousSession;

    if (previousSession != null) {
      _session = await ref
          .read(completeStudySessionUseCaseProvider)
          .call(previousSession);
    }

    final restored = pendingUndo.previousState.copyWith(lastRated: null);
    state = AsyncValue<ReviewState>.data(restored);
    await _persistSnapshot(restored);
    return true;
  }

  Future<ReviewState> _startSession(int deckId) async {
    final cards = await ref
        .read(getDueCardsUseCaseProvider)
        .call(deckId: deckId, limit: _reviewSessionCardLimit);

    if (cards.isEmpty) {
      _session = null;
      _pendingUndo = null;
      await _clearSnapshot();
      return const ReviewState(
        cards: <FlashcardEntity>[],
        currentIndex: 0,
        nextReviewTimes: <ReviewRating, String>{},
      );
    }

    _pendingUndo = null;
    _session = await ref
        .read(startStudySessionUseCaseProvider)
        .call(deckId: deckId);
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
        payload: _encodeState(current),
      ),
    );
  }

  Future<ReviewState?> _restoreSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    final snapshot = store.load();

    if (snapshot == null) {
      return null;
    }

    if (snapshot.deckId != deckId || snapshot.mode != StudyMode.review) {
      return null;
    }

    _pendingUndo = null;
    _session = snapshot.session;
    return ReviewState(
      cards: (snapshot.payload['cards'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (card) => FlashcardEntity.fromJson(
              Map<String, dynamic>.from(card as Map),
            ),
          )
          .toList(growable: false),
      currentIndex: snapshot.payload['currentIndex'] as int? ?? 0,
      nextReviewTimes: (snapshot.payload['nextReviewTimes'] as Map?) == null
          ? const <ReviewRating, String>{}
          : (snapshot.payload['nextReviewTimes'] as Map).map(
              (key, value) => MapEntry<ReviewRating, String>(
                ReviewRating.values.byName(key as String),
                value as String,
              ),
            ),
      isFlipped: snapshot.payload['isFlipped'] as bool? ?? false,
      results:
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
              .toList(growable: false),
    );
  }
}
