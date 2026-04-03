import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folders_provider.g.dart';

typedef HomeDueSummary = ({int dueCardCount, DeckEntity? firstDueDeck});

@riverpod
Stream<List<FolderEntity>> folders(Ref ref) {
  return ref.watch(getRootFoldersUseCaseProvider).call();
}

@riverpod
Stream<List<FolderEntity>> allFolders(Ref ref) {
  return ref.watch(folderRepositoryProvider).watchAll();
}

@riverpod
Stream<List<FolderEntity>> subfolder(Ref ref, int parentId) {
  return ref.watch(getSubfoldersUseCaseProvider).call(parentId);
}

@riverpod
Stream<List<DeckEntity>> allDecks(Ref ref) {
  return ref.watch(getDecksUseCaseProvider).call();
}

@riverpod
Stream<List<FlashcardEntity>> allFlashcards(Ref ref) {
  return ref.watch(getFlashcardsUseCaseProvider).call();
}

@riverpod
AsyncValue<HomeDueSummary> homeDueSummary(Ref ref) {
  final decksAsync = ref.watch(allDecksProvider);
  final cardsAsync = ref.watch(allFlashcardsProvider);
  final error = decksAsync.asError ?? cardsAsync.asError;

  if (error != null) {
    return AsyncValue<HomeDueSummary>.error(error.error, error.stackTrace);
  }

  if (decksAsync.isLoading || cardsAsync.isLoading) {
    return const AsyncValue<HomeDueSummary>.loading();
  }

  final decks = decksAsync.requireValue;
  final dueCards = _dueCards(cardsAsync.requireValue);
  final dueDeckIds = dueCards.map((FlashcardEntity card) => card.deckId).toSet();
  DeckEntity? firstDueDeck;

  for (final deck in decks) {
    if (!dueDeckIds.contains(deck.id)) {
      continue;
    }

    firstDueDeck = deck;
    break;
  }

  return AsyncValue<HomeDueSummary>.data(
    (dueCardCount: dueCards.length, firstDueDeck: firstDueDeck),
  );
}

List<FlashcardEntity> _dueCards(List<FlashcardEntity> cards) {
  final now = DateTime.now();
  return cards.where((FlashcardEntity card) => _isDue(card, now)).toList();
}

bool _isDue(FlashcardEntity card, DateTime now) {
  if (card.status == CardStatus.newCard) {
    return true;
  }

  return switch (card.nextReviewDate) {
    null => false,
    final nextReviewDate => !nextReviewDate.isAfter(now),
  };
}
