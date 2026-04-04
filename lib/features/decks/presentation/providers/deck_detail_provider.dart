import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/presentation/providers/cards_by_deck_provider.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
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
  final deckAsync = ref.watch(deckByIdProvider(deckId));
  final cardsAsync = ref.watch(cardsByDeckProvider(deckId));
  final error = deckAsync.asError ?? cardsAsync.asError;

  if (error != null) {
    return AsyncValue<DeckDetailData>.error(error.error, error.stackTrace);
  }

  if (deckAsync.isLoading || cardsAsync.isLoading) {
    return const AsyncValue<DeckDetailData>.loading();
  }

  final deck = deckAsync.requireValue;

  if (deck == null) {
    return AsyncValue<DeckDetailData>.error(
      StateError('Deck $deckId not found'),
      StackTrace.current,
    );
  }

  final breadcrumbAsync = ref.watch(folderBreadcrumbProvider(deck.folderId));
  final extraError = breadcrumbAsync.asError;

  if (extraError != null) {
    return AsyncValue<DeckDetailData>.error(
      extraError.error,
      extraError.stackTrace,
    );
  }

  if (breadcrumbAsync.isLoading) {
    return const AsyncValue<DeckDetailData>.loading();
  }

  final cards = cardsAsync.requireValue;

  return AsyncValue<DeckDetailData>.data((
    deck: deck,
    breadcrumb: breadcrumbAsync.requireValue,
    cards: cards,
    stats: _deckStats(cards),
  ));
}

@riverpod
Stream<DeckEntity?> deckById(Ref ref, int deckId) =>
    ref.watch(deckRepositoryProvider).watchById(deckId);

DeckStats _deckStats(List<FlashcardEntity> cards) {
  final now = DateTime.now();
  var due = 0;
  var known = 0;
  var learning = 0;
  var newCards = 0;

  for (final card in cards) {
    if (_isDue(card, now)) {
      due++;
    }

    if (card.status == CardStatus.mastered) {
      known++;
      continue;
    }

    if (card.status == CardStatus.newCard) {
      newCards++;
      continue;
    }

    if (card.status == CardStatus.learning ||
        card.status == CardStatus.reviewing) {
      learning++;
    }
  }

  final mastery = cards.isEmpty ? 0.0 : known / cards.length;
  return (
    total: cards.length,
    due: due,
    known: known,
    learning: learning,
    newCards: newCards,
    mastery: mastery,
  );
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
