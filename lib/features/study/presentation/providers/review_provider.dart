import 'package:drift/drift.dart' show Value;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
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

ReviewState? _stateValueOrNull(AsyncValue<ReviewState> value) => switch (value) {
  AsyncData<ReviewState>(:final value) => value,
  _ => null,
};

@Riverpod(keepAlive: true)
class ReviewSession extends _$ReviewSession {
  StudySession? _session;

  @override
  Future<ReviewState> build(int deckId) => _startSession(deckId);

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

    state = AsyncValue<ReviewState>.data(current.copyWith(isFlipped: !current.isFlipped));
  }

  Future<void> startSession() async {
    state = const AsyncValue<ReviewState>.loading();
    state = AsyncValue<ReviewState>.data(await _startSession(deckId));
  }

  Future<void> _advance(
    ReviewState current,
    int cardId,
    ReviewRating rating,
  ) async {
    final nextResults = <ReviewResult>[
      ...current.results,
      (cardId: cardId, rating: rating),
    ];

    if (current.currentIndex == current.cards.length - 1) {
      final completed = current.copyWith(results: nextResults, isComplete: true);
      state = AsyncValue<ReviewState>.data(completed);
      await _completeSession(completed);
      return;
    }

    final nextIndex = current.currentIndex + 1;
    final nextCard = current.cards[nextIndex];
    state = AsyncValue<ReviewState>.data(
      current.copyWith(
        currentIndex: nextIndex,
        nextReviewTimes: _nextReviewTimes(nextCard),
        isFlipped: false,
        selectedRating: null,
        results: nextResults,
      ),
    );
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
  }

  Map<ReviewRating, String> _nextReviewTimes(FlashcardEntity card) =>
      ref.read(srsEngineProvider).getNextReviewTimes(card);

  Future<void> _persistReview(
    FlashcardEntity card,
    ReviewRating rating,
  ) async {
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
      return;
    }

    await ref
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

  Future<ReviewState> _startSession(int deckId) async {
    final cards = await ref
        .read(getDueCardsUseCaseProvider)
        .call(deckId: deckId, limit: _reviewSessionCardLimit);

    if (cards.isEmpty) {
      _session = null;
      return const ReviewState(
        cards: <FlashcardEntity>[],
        currentIndex: 0,
        nextReviewTimes: <ReviewRating, String>{},
      );
    }

    _session = await ref
        .read(startStudySessionUseCaseProvider)
        .call(deckId: deckId);
    return ReviewState(
      cards: cards,
      currentIndex: 0,
      nextReviewTimes: _nextReviewTimes(cards.first),
    );
  }
}
