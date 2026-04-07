import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fill_provider.freezed.dart';
part 'fill_provider.g.dart';

typedef FillCardResult = ({
  String cardId,
  FillResult firstAttemptResult,
  bool acceptedAsClose,
  int retryCount,
});

@freezed
abstract class FillState with _$FillState {
  const factory FillState({
    required List<FlashcardEntity> cards,
    required int currentIndex,
    required FillPrompt currentPrompt,
    required String userInput,
    FillResult? result,
    FillResult? firstAttemptResult,
    String? submittedAnswer,
    @Default(false) bool isRetrying,
    @Default(0) int retryCount,
    @Default(false) bool showHint,
    @Default(0) int streak,
    @Default(0) int bestStreak,
    @Default(<FillCardResult>[]) List<FillCardResult> results,
    @Default(false) bool isComplete,
  }) = _FillState;
}

extension FillStateX on FillState {
  int get acceptedCloseCount =>
      results.where((item) => item.acceptedAsClose).length;

  bool get canPracticeMistakes =>
      results.any((item) => item.firstAttemptResult != FillResult.correct);

  bool get canSkip => isRetrying && retryCount >= 1;

  bool get canSubmit => userInput.trim().isNotEmpty;

  FlashcardEntity? get currentCard {
    if (cards.isEmpty || isComplete) {
      return null;
    }

    return cards[currentIndex];
  }

  int get displayIndex => totalCards == 0 ? 0 : currentIndex + 1;

  int get firstTryCorrectCount => results
      .where(
        (item) =>
            item.firstAttemptResult == FillResult.correct &&
            !item.acceptedAsClose,
      )
      .length;

  int get neededRetryCount =>
      results.where((item) => item.retryCount > 0).length;

  int get totalCards => cards.length;
}

FillState? _stateValueOrNull(AsyncValue<FillState> value) => switch (value) {
  AsyncData<FillState>(:final value) => value,
  _ => null,
};

FillPrompt _emptyPrompt() =>
    (sentenceWithBlank: '', correctAnswer: '', hint: null, answerLength: 0);

@riverpod
Duration fillAutoAdvanceDelay(Ref ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return settings?.autoAdvanceDuration ??
      AppSettings.defaults.autoAdvanceDuration;
}

@riverpod
Duration fillWrongClearDelay(Ref ref) => DurationTokens.wrongClear;

@riverpod
math.Random fillRandom(Ref ref, int deckId) => math.Random();

@Riverpod(keepAlive: true)
class FillSession extends _$FillSession {
  StudySession? _session;
  var _interactionSequence = 0;

  @override
  Future<FillState> build(int deckId) => _startSession(deckId);

  Future<void> acceptClose() async {
    final current = _stateValueOrNull(state);
    final card = current?.currentCard;

    if (current == null || card == null || current.result != FillResult.close) {
      return;
    }

    await _persistReview(
      card,
      true,
      current.submittedAnswer ?? current.userInput,
    );
    await _finalizeCard(
      current: current.copyWith(result: FillResult.correct),
      firstAttemptResult: FillResult.close,
      acceptedAsClose: true,
      streakAfterCard: current.streak + 1,
    );
  }

  Future<void> practiceMistakes() async {
    final current = _stateValueOrNull(state);

    if (current == null ||
        !current.isComplete ||
        !current.canPracticeMistakes) {
      return;
    }

    _interactionSequence++;
    state = const AsyncValue<FillState>.loading();
    state = AsyncValue<FillState>.data(
      await _startWithCards(_practiceCards(current)),
    );
  }

  Future<void> rejectClose() async {
    final current = _stateValueOrNull(state);
    final card = current?.currentCard;

    if (current == null || card == null || current.result != FillResult.close) {
      return;
    }

    await _persistReview(
      card,
      false,
      current.submittedAnswer ?? current.userInput,
    );
    await _enterRetry(
      current: current.copyWith(firstAttemptResult: FillResult.close),
      firstAttemptResult: FillResult.close,
    );
  }

  Future<void> retrySubmit() async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete || !current.isRetrying) {
      return;
    }

    if (!current.canSubmit) {
      return;
    }

    final result = ref
        .read(fillEngineProvider)
        .checkAnswer(current.userInput, current.currentPrompt.correctAnswer);

    if (result == FillResult.wrong) {
      await _clearForRetry(
        current.copyWith(
          result: FillResult.wrong,
          retryCount: current.retryCount + 1,
        ),
      );
      return;
    }

    await _finalizeCard(
      current: current.copyWith(result: FillResult.correct),
      firstAttemptResult: current.firstAttemptResult ?? FillResult.wrong,
      acceptedAsClose: false,
      streakAfterCard: 0,
    );
  }

  Future<void> skipCard() async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete || !current.canSkip) {
      return;
    }

    await _advance(
      current.copyWith(
        results: [
          ...current.results,
          (
            cardId: '${current.currentCard?.id ?? ''}',
            firstAttemptResult: current.firstAttemptResult ?? FillResult.wrong,
            acceptedAsClose: false,
            retryCount: current.retryCount,
          ),
        ],
      ),
    );
  }

  Future<void> startSession() async {
    _interactionSequence++;
    state = const AsyncValue<FillState>.loading();
    state = AsyncValue<FillState>.data(await _startSession(deckId));
  }

  Future<void> submitAnswer() async {
    final current = _stateValueOrNull(state);
    final card = current?.currentCard;

    if (current == null || card == null || current.isComplete) {
      return;
    }

    if (!current.canSubmit) {
      return;
    }

    if (current.isRetrying) {
      await retrySubmit();
      return;
    }

    if (current.result == FillResult.close ||
        current.result == FillResult.correct) {
      return;
    }

    final result = ref
        .read(fillEngineProvider)
        .checkAnswer(current.userInput, current.currentPrompt.correctAnswer);
    final updated = current.copyWith(
      result: result,
      firstAttemptResult: result,
      submittedAnswer: current.userInput.trim(),
    );

    if (result == FillResult.correct) {
      await _persistReview(card, true, updated.submittedAnswer!);
      await _finalizeCard(
        current: updated,
        firstAttemptResult: FillResult.correct,
        acceptedAsClose: false,
        streakAfterCard: current.streak + 1,
      );
      return;
    }

    state = AsyncValue<FillState>.data(updated);

    if (result == FillResult.close) {
      return;
    }

    await _persistReview(card, false, updated.submittedAnswer!);
    await _enterRetry(current: updated, firstAttemptResult: FillResult.wrong);
  }

  Future<void> toggleHint() async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete || current.showHint) {
      return;
    }

    if (current.currentPrompt.hint == null) {
      return;
    }

    state = AsyncValue<FillState>.data(current.copyWith(showHint: true));
  }

  Future<void> updateInput(String text) async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete) {
      return;
    }

    if (current.result == FillResult.close ||
        current.result == FillResult.correct) {
      return;
    }

    if (text == current.userInput) {
      return;
    }

    state = AsyncValue<FillState>.data(current.copyWith(userInput: text));
  }

  Future<void> _advance(FillState current) async {
    if (current.currentIndex == current.cards.length - 1) {
      final completed = current.copyWith(isComplete: true);
      state = AsyncValue<FillState>.data(completed);
      await _completeSession(completed);
      return;
    }

    final nextIndex = current.currentIndex + 1;
    state = AsyncValue<FillState>.data(
      current.copyWith(
        currentIndex: nextIndex,
        currentPrompt: _promptFor(current.cards[nextIndex]),
        userInput: '',
        result: null,
        firstAttemptResult: null,
        submittedAnswer: null,
        isRetrying: false,
        retryCount: 0,
        showHint: false,
      ),
    );
  }

  Future<void> _clearForRetry(FillState current) async {
    final sequence = ++_interactionSequence;
    state = AsyncValue<FillState>.data(current);
    await Future<void>.delayed(ref.read(fillWrongClearDelayProvider));
    final latest = _stateValueOrNull(state);

    if (!_isCurrentInteraction(latest, sequence)) {
      return;
    }

    state = AsyncValue<FillState>.data(
      latest!.copyWith(userInput: '', result: FillResult.wrong),
    );
  }

  Future<void> _completeSession(FillState current) async {
    final session = _session;

    if (session == null) {
      return;
    }

    final now = DateTime.now();
    final startedAt = session.startedAt ?? now;
    final completedSession = session.copyWith(
      completedAt: now,
      totalCards: current.totalCards,
      correctCount: current.firstTryCorrectCount + current.acceptedCloseCount,
      wrongCount: current.neededRetryCount,
      durationSeconds: now.difference(startedAt).inSeconds,
    );
    _session = await ref
        .read(completeStudySessionUseCaseProvider)
        .call(completedSession);
  }

  Future<void> _enterRetry({
    required FillState current,
    required FillResult firstAttemptResult,
  }) async {
    await _clearForRetry(
      current.copyWith(
        firstAttemptResult: firstAttemptResult,
        isRetrying: true,
        retryCount: current.retryCount + 1,
        showHint: current.showHint || current.currentPrompt.hint != null,
        streak: 0,
      ),
    );
  }

  Future<void> _finalizeCard({
    required FillState current,
    required FillResult firstAttemptResult,
    required bool acceptedAsClose,
    required int streakAfterCard,
  }) async {
    final sequence = ++_interactionSequence;
    final updated = current.copyWith(
      results: [
        ...current.results,
        (
          cardId: '${current.currentCard?.id ?? ''}',
          firstAttemptResult: firstAttemptResult,
          acceptedAsClose: acceptedAsClose,
          retryCount: current.retryCount,
        ),
      ],
      streak: streakAfterCard,
      bestStreak: math.max(current.bestStreak, streakAfterCard),
      isRetrying: false,
      userInput: current.currentPrompt.correctAnswer,
    );
    state = AsyncValue<FillState>.data(updated);
    await Future<void>.delayed(ref.read(fillAutoAdvanceDelayProvider));
    final latest = _stateValueOrNull(state);

    if (!_isCurrentInteraction(latest, sequence)) {
      return;
    }

    await _advance(latest!);
  }

  bool _isCurrentInteraction(FillState? stateValue, int sequence) {
    if (stateValue == null) {
      return false;
    }

    return _interactionSequence == sequence;
  }

  Future<void> _persistReview(
    FlashcardEntity card,
    bool isCorrect,
    String userAnswer,
  ) async {
    final review = ref
        .read(srsEngineProvider)
        .processFillResult(card, isCorrect: isCorrect);
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
            mode: StudyMode.fill,
            rating: Value(
              isCorrect ? ReviewRating.good.index : ReviewRating.again.index,
            ),
            isCorrect: isCorrect,
            userAnswer: Value(userAnswer),
            reviewedAt: now,
          ),
        );
  }

  List<FlashcardEntity> _practiceCards(FillState current) {
    final mistakeIds = current.results
        .where((item) => item.firstAttemptResult != FillResult.correct)
        .map((item) => item.cardId)
        .toSet();
    return current.cards
        .where((card) => mistakeIds.contains('${card.id}'))
        .toList();
  }

  FillPrompt _promptFor(FlashcardEntity card) =>
      ref.read(fillEngineProvider).generatePrompt(card);

  List<FlashcardEntity> _shuffleCards(List<FlashcardEntity> cards) {
    final shuffled = [...cards]..shuffle(ref.read(fillRandomProvider(deckId)));
    return shuffled;
  }

  Future<FillState> _startSession(int deckId) async {
    final loadedCards = await ref
        .read(getCardsByDeckUseCaseProvider)
        .call(deckId)
        .first;
    return _startWithCards(_shuffleCards(loadedCards));
  }

  Future<FillState> _startWithCards(List<FlashcardEntity> cards) async {
    _interactionSequence = 0;

    if (cards.isEmpty) {
      _session = null;
      return FillState(
        cards: const <FlashcardEntity>[],
        currentIndex: 0,
        currentPrompt: _emptyPrompt(),
        userInput: '',
      );
    }

    _session = await ref
        .read(startStudySessionUseCaseProvider)
        .call(deckId: cards.first.deckId, mode: StudyMode.fill);
    return FillState(
      cards: cards,
      currentIndex: 0,
      currentPrompt: _promptFor(cards.first),
      userInput: '',
    );
  }
}
