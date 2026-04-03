import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/presentation/providers/cards_by_deck_provider.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';
import 'package:memox/features/decks/presentation/providers/deck_stats_provider.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
import 'package:memox/features/folders/presentation/providers/folders_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deck_detail_provider.g.dart';

typedef DeckDetailData = ({
  DeckEntity deck,
  List<FolderEntity> breadcrumb,
  List<FlashcardEntity> cards,
  DeckStats stats,
});

@riverpod
AsyncValue<DeckDetailData> deckDetail(Ref ref, int deckId) {
  final decksAsync = ref.watch(allDecksProvider);
  final cardsAsync = ref.watch(cardsByDeckProvider(deckId));
  final error = decksAsync.asError ?? cardsAsync.asError;

  if (error != null) {
    return AsyncValue<DeckDetailData>.error(error.error, error.stackTrace);
  }

  if (decksAsync.isLoading || cardsAsync.isLoading) {
    return const AsyncValue<DeckDetailData>.loading();
  }

  DeckEntity? deck;

  for (final item in decksAsync.requireValue) {
    if (item.id == deckId) {
      deck = item;
      break;
    }
  }

  if (deck == null) {
    return AsyncValue<DeckDetailData>.error(
      StateError('Deck $deckId not found'),
      StackTrace.current,
    );
  }

  final breadcrumbAsync = ref.watch(folderBreadcrumbProvider(deck.folderId));
  final statsAsync = ref.watch(deckStatsProvider(deckId));
  final extraError = breadcrumbAsync.asError ?? statsAsync.asError;

  if (extraError != null) {
    return AsyncValue<DeckDetailData>.error(
      extraError.error,
      extraError.stackTrace,
    );
  }

  if (breadcrumbAsync.isLoading || statsAsync.isLoading) {
    return const AsyncValue<DeckDetailData>.loading();
  }

  return AsyncValue<DeckDetailData>.data((
    deck: deck,
    breadcrumb: breadcrumbAsync.requireValue,
    cards: cardsAsync.requireValue,
    stats: statsAsync.requireValue,
  ));
}
