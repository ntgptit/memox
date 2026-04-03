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
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guess_provider.freezed.dart';
part 'guess_provider.g.dart';

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
    @Default(<bool>[]) List<bool> results,
    @Default(false) bool isComplete,
  }) = _GuessState;
}

extension GuessStateX on GuessState {
  int get totalCards => cards.length;

  int get correctCount => results.where((value) => value).length;

  int get accuracy =>
      totalCards == 0 ? 0 : ((correctCount / totalCards) * 100).round();

  int get displayIndex => totalCards == 0 ? 0 : currentIndex + 1;

  bool get canContinue => isAnswered && isCorrect == false;

  FlashcardEntity? get currentCard {
    if (cards.isEmpty || isComplete) {
      return null;
    }

    return cards[currentIndex];
  }
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
  Future<GuessState> build(int deckId) => _startSession(deckId);

  Future<void> nextQuestion() async {
    final current = _stateValueOrNull(state);

    if (current == null || current.isComplete || !current.isAnswered) {
      return;
    }

    _interactionSequence++;

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
    state = AsyncValue<GuessState>.data(
      current.copyWith(
        currentIndex: nextIndex,
        currentQuestion: nextQuestion,
        selectedOptionIndex: null,
        isAnswered: false,
        isCorrect: null,
      ),
    );
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
    final nextStreak = isCorrect ? current.streak + 1 : 0;
    final updated = current.copyWith(
      selectedOptionIndex: index,
      isAnswered: true,
      isCorrect: isCorrect,
      streak: nextStreak,
      bestStreak: math.max(current.bestStreak, nextStreak),
      results: [...current.results, isCorrect],
    );
    final sequence = ++_interactionSequence;
    state = AsyncValue<GuessState>.data(updated);
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

    if (current == null || current.isComplete || current.isAnswered) {
      return;
    }

    if (current.cards.isEmpty) {
      return;
    }

    _interactionSequence++;
    final cards = [...current.cards];
    final skippedCard = cards.removeAt(current.currentIndex);
    cards.add(skippedCard);
    final nextQuestion = ref
        .read(guessEngineProvider(deckId))
        .generateQuestion(cards[current.currentIndex], cards);
    state = AsyncValue<GuessState>.data(
      current.copyWith(cards: cards, currentQuestion: nextQuestion),
    );
  }

  Future<void> startSession() async {
    _interactionSequence++;
    state = const AsyncValue<GuessState>.loading();
    state = AsyncValue<GuessState>.data(await _startSession(deckId));
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
    _session = await ref
        .read(completeStudySessionUseCaseProvider)
        .call(completedSession);
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
      return GuessState(
        cards: const <FlashcardEntity>[],
        currentIndex: 0,
        currentQuestion: _emptyQuestion(),
      );
    }

    _session = await ref
        .read(startStudySessionUseCaseProvider)
        .call(deckId: deckId, mode: StudyMode.guess);
    return GuessState(
      cards: cards,
      currentIndex: 0,
      currentQuestion: engine.generateQuestion(cards.first, cards),
    );
  }
}
