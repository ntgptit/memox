import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'next_due_deck_provider.g.dart';

@riverpod
Stream<List<DeckEntity>> _studyDecks(Ref ref) =>
    ref.watch(deckRepositoryProvider).watchAll();

@riverpod
Stream<List<FlashcardEntity>> _studyCards(Ref ref) =>
    ref.watch(flashcardRepositoryProvider).watchAll();

@riverpod
AsyncValue<DeckEntity?> nextDueDeck(Ref ref, int currentDeckId) {
  final decksAsync = ref.watch(_studyDecksProvider);
  final cardsAsync = ref.watch(_studyCardsProvider);
  final error = decksAsync.asError ?? cardsAsync.asError;

  if (error != null) {
    return AsyncValue<DeckEntity?>.error(error.error, error.stackTrace);
  }

  if (decksAsync.isLoading || cardsAsync.isLoading) {
    return const AsyncValue<DeckEntity?>.loading();
  }

  final dueDeckIds = _dueDeckIds(cardsAsync.requireValue);

  for (final deck in decksAsync.requireValue) {
    if (deck.id == currentDeckId || !dueDeckIds.contains(deck.id)) {
      continue;
    }

    return AsyncValue<DeckEntity?>.data(deck);
  }

  return const AsyncValue<DeckEntity?>.data(null);
}

Set<int> _dueDeckIds(List<FlashcardEntity> cards) {
  final now = DateTime.now();
  return cards
      .where((card) => _isDue(card, now))
      .map((card) => card.deckId)
      .toSet();
}

bool _isDue(FlashcardEntity card, DateTime now) {
  if (card.status == CardStatus.newCard) {
    return true;
  }

  final nextReviewDate = card.nextReviewDate;

  if (nextReviewDate == null) {
    return false;
  }

  return !nextReviewDate.isAfter(now);
}
