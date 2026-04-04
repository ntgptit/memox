import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_recursive_stats.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folders_provider.g.dart';

typedef HomeDueSummary = ({int dueCardCount, DeckEntity? firstDueDeck});
typedef HomeFolderTileData = ({
  int directSubfolderCount,
  int directDeckCount,
  int totalCards,
  double masteryPercentage,
});

@Riverpod(keepAlive: true)
Stream<List<FolderEntity>> folders(Ref ref) =>
    ref.watch(getRootFoldersUseCaseProvider).call();

@Riverpod(keepAlive: true)
Stream<List<FolderEntity>> allFolders(Ref ref) =>
    ref.watch(folderRepositoryProvider).watchAll();

@riverpod
Stream<List<FolderEntity>> subfolder(Ref ref, int parentId) =>
    ref.watch(getSubfoldersUseCaseProvider).call(parentId);

@Riverpod(keepAlive: true)
Stream<List<DeckEntity>> allDecks(Ref ref) =>
    ref.watch(getDecksUseCaseProvider).call();

@Riverpod(keepAlive: true)
Stream<List<FlashcardEntity>> allFlashcards(Ref ref) =>
    ref.watch(getFlashcardsUseCaseProvider).call();

@riverpod
Stream<List<DeckEntity>> decksByFolder(Ref ref, int folderId) =>
    ref.watch(getDecksByFolderUseCaseProvider).call(folderId);

@riverpod
Stream<FolderRecursiveStats> folderRecursiveStats(Ref ref, int folderId) =>
    ref.watch(folderRepositoryProvider).watchRecursiveStats(folderId);

@riverpod
AsyncValue<HomeFolderTileData> homeFolderTileData(Ref ref, int folderId) {
  final subfoldersAsync = ref.watch(subfolderProvider(folderId));
  final decksAsync = ref.watch(decksByFolderProvider(folderId));
  final statsAsync = ref.watch(folderRecursiveStatsProvider(folderId));
  final error =
      subfoldersAsync.asError ?? decksAsync.asError ?? statsAsync.asError;

  if (error != null) {
    return AsyncValue<HomeFolderTileData>.error(error.error, error.stackTrace);
  }

  if (subfoldersAsync.isLoading ||
      decksAsync.isLoading ||
      statsAsync.isLoading) {
    return const AsyncValue<HomeFolderTileData>.loading();
  }

  final stats = statsAsync.requireValue;
  return AsyncValue<HomeFolderTileData>.data((
    directSubfolderCount: subfoldersAsync.requireValue.length,
    directDeckCount: decksAsync.requireValue.length,
    totalCards: stats.totalCards,
    masteryPercentage: stats.masteryPercentage,
  ));
}

@Riverpod(keepAlive: true)
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
  final dueDeckIds = dueCards
      .map((FlashcardEntity card) => card.deckId)
      .toSet();
  DeckEntity? firstDueDeck;

  for (final deck in decks) {
    if (!dueDeckIds.contains(deck.id)) {
      continue;
    }

    firstDueDeck = deck;
    break;
  }

  return AsyncValue<HomeDueSummary>.data((
    dueCardCount: dueCards.length,
    firstDueDeck: firstDueDeck,
  ));
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
