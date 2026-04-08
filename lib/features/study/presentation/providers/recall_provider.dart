import 'dart:math' as math;

import 'package:characters/characters.dart';
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
    @Default(false) bool isMissedPracticeSession,
    @Default(false) bool isRevealed,
    SelfRating? selfRating,
    @Default(<RecallResult>[]) List<RecallResult> results,
    @Default(false) bool isComplete,
  }) = _RecallState;
}

extension RecallStateX on RecallState {
  int get totalCards => cards.length;

  int get displayIndex => totalCards == 0 ? 0 : currentIndex + 1;

  bool get canReveal {
    final answerLength = currentCard?.front.trim().characters.length ?? 0;
    final minimumLength = math.max(1, math.min(3, answerLength));
    return userAnswer.trim().characters.length >= minimumLength;
  }

  FlashcardEntity? get currentCard {
    if (cards.isEmpty || isComplete) {
      return null;
    }

    return cards[currentIndex];
  }

  int get gotItCount =>
      results.where((result) => result.rating == SelfRating.gotIt).length;

  int get partialCount =>
      results.where((result) => result.rating == SelfRating.partial).length;

  int get missedCount =>
      results.where((result) => result.rating == SelfRating.missed).length;
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

  Future<void> reviewMissedCards() async {
    final current = _stateValueOrNull(state);

    if (current == null || !current.isComplete || current.missedCount == 0) {
      return;
    }

    _interactionSequence++;
    state = const AsyncValue<RecallState>.loading();
    final nextState = await _startWithCards(
      _missedCards(current),
      isMissedPracticeSession: true,
    );
    state = AsyncValue<RecallState>.data(nextState);
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

    final updated = current.copyWith(
      selfRating: SelfRating.missed,
      results: [
        ...current.results,
        (
          cardId: card.id,
          userAnswer: current.userAnswer,
          rating: SelfRating.missed,
        ),
      ],
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

    final updated = current.copyWith(
      selfRating: rating,
      results: [
        ...current.results,
        (cardId: card.id, userAnswer: current.userAnswer, rating: rating),
      ],
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
    if (current.currentIndex == current.cards.length - 1) {
      final completed = current.copyWith(isComplete: true);
      state = AsyncValue<RecallState>.data(completed);
      await _completeSession(completed);
      return;
    }

    final updated = current.copyWith(
      currentIndex: current.currentIndex + 1,
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
    _session = await ref
        .read(completeStudySessionUseCaseProvider)
        .call(completedSession);
    await _clearSnapshot();
  }

  List<FlashcardEntity> _missedCards(RecallState current) {
    final missedIds = current.results
        .where((result) => result.rating == SelfRating.missed)
        .map((result) => result.cardId)
        .toSet();
    return current.cards.where((card) => missedIds.contains(card.id)).toList();
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
    return _startWithCards(_shuffleCards(loadedCards));
  }

  Future<RecallState> _startWithCards(
    List<FlashcardEntity> cards, {
    bool isMissedPracticeSession = false,
  }) async {
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

    _session = await _startRecallSession(
      deckId: cards.first.deckId,
      isMissedPracticeSession: isMissedPracticeSession,
    );
    final nextState = RecallState(
      cards: cards,
      currentIndex: 0,
      userAnswer: '',
      isMissedPracticeSession: isMissedPracticeSession,
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
    'isMissedPracticeSession': current.isMissedPracticeSession,
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
        payload: _encodeState(current),
      ),
    );
  }

  Future<RecallState?> _restoreSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    final snapshot = store.load();

    if (snapshot == null) {
      return null;
    }

    if (snapshot.deckId != deckId || snapshot.mode != StudyMode.recall) {
      return null;
    }

    _interactionSequence = 0;
    _session = snapshot.session;
    return RecallState(
      cards: (snapshot.payload['cards'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (card) => FlashcardEntity.fromJson(
              Map<String, dynamic>.from(card as Map),
            ),
          )
          .toList(growable: false),
      currentIndex: snapshot.payload['currentIndex'] as int? ?? 0,
      userAnswer: snapshot.payload['userAnswer'] as String? ?? '',
      isMissedPracticeSession:
          snapshot.payload['isMissedPracticeSession'] as bool? ?? false,
      isRevealed: snapshot.payload['isRevealed'] as bool? ?? false,
      selfRating: snapshot.payload['selfRating'] == null
          ? null
          : SelfRating.values.byName(snapshot.payload['selfRating'] as String),
      results:
          (snapshot.payload['results'] as List<dynamic>? ?? const <dynamic>[])
              .map(
                (result) => (
                  cardId: (result as Map)['cardId'] as int,
                  userAnswer: result['userAnswer'] as String? ?? '',
                  rating: SelfRating.values.byName(
                    result['rating'] as String? ?? SelfRating.missed.name,
                  ),
                ),
              )
              .toList(growable: false),
    );
  }

  Future<StudySession?> _startRecallSession({
    required int deckId,
    required bool isMissedPracticeSession,
  }) async {
    if (isMissedPracticeSession) {
      return null;
    }

    return ref
        .read(startStudySessionUseCaseProvider)
        .call(deckId: deckId, mode: StudyMode.recall);
  }
}
