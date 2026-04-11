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
import 'package:memox/features/study/domain/guess/guess_engine.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
import 'package:memox/features/study/presentation/support/study_restore_utils.dart';
import 'package:memox/features/study/presentation/support/study_session_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guess_provider.freezed.dart';
part 'guess_provider.g.dart';

typedef GuessResult = ({int cardId, bool isCorrect, bool skipped});

@freezed
abstract class GuessState with _$GuessState {
  const factory GuessState({
    required List<FlashcardEntity> cards,
    required int currentIndex,
    required GuessQuestion currentQuestion,
    int? selectedOptionIndex,
    @Default(false) bool isAnswered,
    bool? isCorrect,
    @Default(0) int streak,
    @Default(0) int bestStreak,
    @Default(<GuessResult>[]) List<GuessResult> results,
    @Default(<int, int>{}) Map<int, int> skipCounts,
    @Default(<int>{}) Set<int> retryPendingCardIds,
    @Default(false) bool isComplete,
  }) = _GuessState;
}

extension GuessStateX on GuessState {
  static const int skipLimit = 2;

  int get totalCards => cards.length;

  int get correctCount => results.where((value) => value.isCorrect).length;

  int get accuracy =>
      totalCards == 0 ? 0 : ((correctCount / totalCards) * 100).round();

  int get displayIndex => totalCards == 0 ? 0 : currentIndex + 1;

  int get skippedCount => results.where((value) => value.skipped).length;

  bool get canContinue => isAnswered;

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

    if (isAnswered) {
      return const <StudySessionAllowedAction>[
        StudySessionAllowedAction.goNext,
      ];
    }

    return const <StudySessionAllowedAction>[
      StudySessionAllowedAction.submitAnswer,
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

  int get currentSkipCount =>
      currentCard == null ? 0 : (skipCounts[currentCard!.id] ?? 0);

  bool get isCurrentCardPendingRetry {
    final card = currentCard;

    if (card == null) {
      return false;
    }

    return retryPendingCardIds.contains(card.id);
  }

  StudySessionModeState get modeState {
    if (isComplete) {
      return StudySessionModeState.completed;
    }

    if (isAnswered) {
      return StudySessionModeState.waitingFeedback;
    }

    if (isCurrentCardPendingRetry) {
      return StudySessionModeState.retryPending;
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
}

GuessState? _stateValueOrNull(AsyncValue<GuessState> value) => switch (value) {
  AsyncData<GuessState>(:final value) => value,
  _ => null,
};

GuessQuestion _emptyQuestion() =>
    (definition: '', options: const <GuessOption>[], correctIndex: 0);

@riverpod
GuessEngine guessEngine(Ref ref, int deckId) => GuessEngine();

@riverpod
Duration guessAutoAdvanceDelay(Ref ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return settings?.autoAdvanceDuration ??
      AppSettings.defaults.autoAdvanceDuration;
}

@Riverpod(keepAlive: true)
class GuessSession extends _$GuessSession {
  StudySession? _session;
  var _interactionSequence = 0;

  @override
  Future<GuessState> build(int deckId) async {
    final restored = await _restoreSnapshot();

    if (restored != null) {
      return restored;
    }

    return _startSession(deckId);
  }

  Future<void> nextQuestion() async {
    final current = _stateValueOrNull(state);
    final currentCard = current?.currentCard;

    if (current == null ||
        currentCard == null ||
        current.isComplete ||
        !current.isAnswered) {
      return;
    }

    _interactionSequence++;

    if (current.isCurrentCardPendingRetry && current.isCorrect == false) {
      final reorderedCards = [...current.cards];
      final retryCard = reorderedCards.removeAt(current.currentIndex);
      reorderedCards.add(retryCard);
      final nextIndex = _nextIndexAfterRetry(
        currentIndex: current.currentIndex,
        cards: reorderedCards,
        retryPendingCardIds: current.retryPendingCardIds,
      );
      final nextQuestion = ref
          .read(guessEngineProvider(deckId))
          .generateQuestion(reorderedCards[nextIndex], reorderedCards);
      final updated = current.copyWith(
        cards: reorderedCards,
        currentIndex: nextIndex,
        currentQuestion: nextQuestion,
        selectedOptionIndex: null,
        isAnswered: false,
        isCorrect: null,
      );
      state = AsyncValue<GuessState>.data(updated);
      await _persistSnapshot(updated);
      return;
    }

    if (current.currentIndex == current.cards.length - 1) {
      final completed = current.copyWith(isComplete: true);
      state = AsyncValue<GuessState>.data(completed);
      await _completeSession(completed);
      return;
    }

    final nextIndex = current.currentIndex + 1;
    final cards = current.cards;
    final nextQuestion = ref
        .read(guessEngineProvider(deckId))
        .generateQuestion(cards[nextIndex], cards);
    final updated = current.copyWith(
      currentIndex: nextIndex,
      currentQuestion: nextQuestion,
      selectedOptionIndex: null,
      isAnswered: false,
      isCorrect: null,
    );
    state = AsyncValue<GuessState>.data(updated);
    await _persistSnapshot(updated);
  }

  Future<void> selectOption(int index) async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete || current.isAnswered) {
      return;
    }

    if (index < 0 || index >= current.currentQuestion.options.length) {
      return;
    }

    final currentCard = current.currentCard;

    if (currentCard == null) {
      return;
    }

    final isCorrect = current.currentQuestion.options[index].isCorrect;
    final isRetryRound = current.retryPendingCardIds.contains(currentCard.id);
    final nextStreak = isCorrect ? current.streak + 1 : 0;
    final nextRetryPendingCardIds = {...current.retryPendingCardIds};
    final nextResults = [...current.results];

    if (isCorrect) {
      nextRetryPendingCardIds.remove(currentCard.id);
      nextResults.add((
        cardId: currentCard.id,
        isCorrect: true,
        skipped: false,
      ));
    }

    if (!isCorrect && isRetryRound) {
      nextRetryPendingCardIds.remove(currentCard.id);
      nextResults.add((
        cardId: currentCard.id,
        isCorrect: false,
        skipped: false,
      ));
    }

    if (!isCorrect && !isRetryRound) {
      nextRetryPendingCardIds.add(currentCard.id);
    }

    final updated = current.copyWith(
      selectedOptionIndex: index,
      isAnswered: true,
      isCorrect: isCorrect,
      streak: nextStreak,
      bestStreak: math.max(current.bestStreak, nextStreak),
      results: nextResults,
      retryPendingCardIds: nextRetryPendingCardIds,
    );
    final sequence = ++_interactionSequence;
    state = AsyncValue<GuessState>.data(updated);
    await _persistSnapshot(updated);
    await _persistGuessReview(currentCard, isCorrect);

    if (!isCorrect) {
      return;
    }

    await Future<void>.delayed(ref.read(guessAutoAdvanceDelayProvider));
    final latest = _stateValueOrNull(state);

    if (!_shouldAutoAdvance(latest, sequence, currentCard.id)) {
      return;
    }

    await nextQuestion();
  }

  Future<void> skipQuestion() async {
    final current = _stateValueOrNull(state);
    final currentCard = current?.currentCard;

    if (current == null || current.isComplete || current.isAnswered) {
      return;
    }

    if (current.cards.isEmpty || currentCard == null) {
      return;
    }

    final currentSkipCount = current.skipCounts[currentCard.id] ?? 0;

    if (currentSkipCount >= GuessStateX.skipLimit) {
      await _markSkippedWrong(current, currentCard);
      return;
    }

    _interactionSequence++;
    final cards = [...current.cards];
    final skippedCard = cards.removeAt(current.currentIndex);
    cards.add(skippedCard);
    final nextIndex = _nextIndexAfterSkip(
      currentIndex: current.currentIndex,
      cardCount: cards.length,
    );
    final nextQuestion = ref
        .read(guessEngineProvider(deckId))
        .generateQuestion(cards[nextIndex], cards);
    final updated = current.copyWith(
      cards: cards,
      currentIndex: nextIndex,
      currentQuestion: nextQuestion,
      skipCounts: {...current.skipCounts, currentCard.id: currentSkipCount + 1},
    );
    state = AsyncValue<GuessState>.data(updated);
    await _persistSnapshot(updated);
  }

  Future<void> startSession() async {
    _interactionSequence++;
    state = const AsyncValue<GuessState>.loading();
    final nextState = await _startSession(deckId);
    state = AsyncValue<GuessState>.data(nextState);
  }

  Future<void> _completeSession(GuessState current) async {
    final session = _session;

    if (session == null) {
      return;
    }

    final startedAt = session.startedAt ?? DateTime.now();
    final completedSession = session.copyWith(
      completedAt: DateTime.now(),
      totalCards: current.totalCards,
      correctCount: current.correctCount,
      wrongCount: current.totalCards - current.correctCount,
      durationSeconds: DateTime.now().difference(startedAt).inSeconds,
    );
    _session = unwrapStudySessionResult(
      await ref
          .read(completeStudySessionUseCaseProvider)
          .call(completedSession),
    );
    await _clearSnapshot();
  }

  Future<void> _markSkippedWrong(
    GuessState current,
    FlashcardEntity card,
  ) async {
    final isRetryRound = current.retryPendingCardIds.contains(card.id);
    final nextRetryPendingCardIds = {...current.retryPendingCardIds};
    final nextResults = [...current.results];

    if (isRetryRound) {
      nextRetryPendingCardIds.remove(card.id);
      nextResults.add((cardId: card.id, isCorrect: false, skipped: true));
    }

    if (!isRetryRound) {
      nextRetryPendingCardIds.add(card.id);
    }

    final updated = current.copyWith(
      selectedOptionIndex: null,
      isAnswered: true,
      isCorrect: false,
      streak: 0,
      results: nextResults,
      retryPendingCardIds: nextRetryPendingCardIds,
    );
    state = AsyncValue<GuessState>.data(updated);
    await _persistSnapshot(updated);
    await _persistGuessReview(card, false);
  }

  Future<void> _persistGuessReview(FlashcardEntity card, bool isCorrect) async {
    final review = ref
        .read(srsEngineProvider)
        .processGuessResult(card, isCorrect: isCorrect);
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
            mode: StudyMode.guess,
            rating: Value(
              isCorrect ? ReviewRating.good.index : ReviewRating.again.index,
            ),
            isCorrect: isCorrect,
            reviewedAt: now,
          ),
        );
  }

  bool _shouldAutoAdvance(GuessState? stateValue, int sequence, int cardId) {
    if (stateValue == null || _interactionSequence != sequence) {
      return false;
    }

    final currentCard = stateValue.currentCard;

    if (currentCard == null) {
      return false;
    }

    return stateValue.isAnswered &&
        stateValue.isCorrect == true &&
        currentCard.id == cardId;
  }

  Future<GuessState> _startSession(int deckId) async {
    final loadedCards = await ref
        .read(getCardsByDeckUseCaseProvider)
        .call(deckId)
        .first;
    final engine = ref.read(guessEngineProvider(deckId));
    final cards = engine.shuffleCards(loadedCards);
    _interactionSequence = 0;

    if (cards.isEmpty) {
      _session = null;
      await _clearSnapshot();
      return GuessState(
        cards: const <FlashcardEntity>[],
        currentIndex: 0,
        currentQuestion: _emptyQuestion(),
      );
    }

    _session = unwrapStudySessionResult(
      await ref
          .read(startStudySessionUseCaseProvider)
          .call(deckId: deckId, mode: StudyMode.guess),
    );
    final nextState = GuessState(
      cards: cards,
      currentIndex: 0,
      currentQuestion: engine.generateQuestion(cards.first, cards),
    );
    await _persistSnapshot(nextState);
    return nextState;
  }

  Future<void> _clearSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.clearIfMatches(deckId: deckId, mode: StudyMode.guess);
  }

  Map<String, dynamic> _encodeState(GuessState current) => <String, dynamic>{
    'cards': current.cards.map((card) => card.toJson()).toList(growable: false),
    'currentIndex': current.currentIndex,
    'currentQuestion': <String, dynamic>{
      'definition': current.currentQuestion.definition,
      'correctIndex': current.currentQuestion.correctIndex,
      'options': current.currentQuestion.options
          .map(
            (option) => <String, dynamic>{
              'text': option.text,
              'cardId': option.cardId,
              'isCorrect': option.isCorrect,
            },
          )
          .toList(growable: false),
    },
    'selectedOptionIndex': current.selectedOptionIndex,
    'isAnswered': current.isAnswered,
    'isCorrect': current.isCorrect,
    'streak': current.streak,
    'bestStreak': current.bestStreak,
    'results': current.results
        .map(
          (result) => <String, dynamic>{
            'cardId': result.cardId,
            'isCorrect': result.isCorrect,
            'skipped': result.skipped,
          },
        )
        .toList(growable: false),
    'skipCounts': Map<String, int>.fromEntries(
      current.skipCounts.entries.map(
        (entry) => MapEntry<String, int>('${entry.key}', entry.value),
      ),
    ),
    'retryPendingCardIds': current.retryPendingCardIds.toList(growable: false),
  };

  Future<void> _persistSnapshot(GuessState current) async {
    if (current.cards.isEmpty || current.isComplete) {
      await _clearSnapshot();
      return;
    }

    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.save(
      ActiveStudySessionSnapshot(
        deckId: deckId,
        mode: StudyMode.guess,
        session: _session,
        modePlan: const <StudyMode>[StudyMode.guess],
        modeState: current.modeState,
        allowedActions: current.allowedActions,
        currentItem: current.currentItemSnapshot,
        progress: current.progressSnapshot,
        sessionCompleted: current.isComplete,
        payload: _encodeState(current),
      ),
    );
  }

  Future<GuessState?> _restoreSnapshot() async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    return store.restoreMatching(
      deckId: deckId,
      mode: StudyMode.guess,
      decode: (snapshot) {
        final cards = _decodeGuessCards(snapshot.payload['cards']);
        final requestedIndex = snapshot.payload['currentIndex'] as int? ?? 0;
        final currentIndex = _restoredGuessIndex(
          snapshot.payload['currentIndex'],
          cards.length,
        );
        final questionNeedsReset = _shouldRebuildGuessQuestion(
          raw: snapshot.payload['currentQuestion'],
          cards: cards,
          requestedIndex: requestedIndex,
          currentIndex: currentIndex,
        );
        final question = questionNeedsReset
            ? ref
                  .read(guessEngineProvider(deckId))
                  .generateQuestion(cards[currentIndex], cards)
            : _decodeQuestion(
                Map<String, dynamic>.from(
                  snapshot.payload['currentQuestion'] as Map,
                ),
              );
        final requestedIsAnswered =
            snapshot.payload['isAnswered'] as bool? ?? false;
        final selectedOptionIndex = _restoredSelectedOptionIndex(
          raw: snapshot.payload['selectedOptionIndex'],
          optionCount: question.options.length,
        );
        final canRestoreAnsweredState =
            requestedIsAnswered &&
            selectedOptionIndex != null &&
            !questionNeedsReset;
        final cardIds = cards.map((card) => card.id).toSet();
        final restored = GuessState(
          cards: cards,
          currentIndex: currentIndex,
          currentQuestion: question,
          selectedOptionIndex: canRestoreAnsweredState
              ? selectedOptionIndex
              : null,
          isAnswered: canRestoreAnsweredState,
          isCorrect: canRestoreAnsweredState
              ? snapshot.payload['isCorrect'] as bool?
              : null,
          streak: snapshot.payload['streak'] as int? ?? 0,
          bestStreak: snapshot.payload['bestStreak'] as int? ?? 0,
          results:
              (snapshot.payload['results'] as List<dynamic>? ??
                      const <dynamic>[])
                  .map(
                    (result) => (
                      cardId: (result as Map)['cardId'] as int,
                      isCorrect: result['isCorrect'] as bool? ?? false,
                      skipped: result['skipped'] as bool? ?? false,
                    ),
                  )
                  .where((result) => cardIds.contains(result.cardId))
                  .toList(growable: false),
          skipCounts:
              (snapshot.payload['skipCounts'] as Map?) == null
                    ? const <int, int>{}
                    : (snapshot.payload['skipCounts'] as Map).map(
                        (key, value) => MapEntry<int, int>(
                          int.parse(key as String),
                          value as int,
                        ),
                      )
                ..removeWhere((key, value) => !cardIds.contains(key)),
          retryPendingCardIds:
              (snapshot.payload['retryPendingCardIds'] as List<dynamic>? ??
                      const <dynamic>[])
                  .map((cardId) => cardId as int)
                  .where(cardIds.contains)
                  .toSet(),
        );
        _interactionSequence = 0;
        _session = snapshot.session;
        return restored;
      },
    );
  }
}

List<FlashcardEntity> _decodeGuessCards(Object? raw) =>
    (raw as List<dynamic>? ?? const <dynamic>[])
        .map(
          (card) =>
              FlashcardEntity.fromJson(Map<String, dynamic>.from(card as Map)),
        )
        .toList(growable: false);

int _restoredGuessIndex(Object? raw, int cardCount) {
  if (cardCount == 0) {
    throw StateError('Guess snapshot is missing cards.');
  }

  return clampSnapshotIndex(raw as int? ?? 0, cardCount);
}

int? _restoredSelectedOptionIndex({
  required Object? raw,
  required int optionCount,
}) {
  final index = raw as int?;

  if (index == null) {
    return null;
  }

  if (index < 0 || index >= optionCount) {
    return null;
  }

  return index;
}

bool _shouldRebuildGuessQuestion({
  required Object? raw,
  required List<FlashcardEntity> cards,
  required int requestedIndex,
  required int currentIndex,
}) {
  if (requestedIndex != currentIndex) {
    return true;
  }

  if (cards.isEmpty || raw is! Map) {
    return true;
  }

  final decoded = _decodeQuestion(Map<String, dynamic>.from(raw));

  if (decoded.options.isEmpty) {
    return true;
  }

  if (decoded.correctIndex < 0 ||
      decoded.correctIndex >= decoded.options.length) {
    return true;
  }

  return false;
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

int _nextIndexAfterSkip({required int currentIndex, required int cardCount}) {
  if (cardCount == 0) {
    return 0;
  }

  if (currentIndex >= cardCount - 1) {
    return 0;
  }

  return currentIndex;
}

GuessQuestion _decodeQuestion(Map<String, dynamic> json) => (
  definition: json['definition'] as String? ?? '',
  options: (json['options'] as List<dynamic>? ?? const <dynamic>[])
      .map(
        (option) => (
          text: (option as Map)['text'] as String? ?? '',
          cardId: option['cardId'] as String? ?? '',
          isCorrect: option['isCorrect'] as bool? ?? false,
        ),
      )
      .toList(growable: false),
  correctIndex: json['correctIndex'] as int? ?? 0,
);
