import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/presentation/providers/folders_provider.dart';
import 'package:memox/features/folders/presentation/widgets/folder_deck_tile.dart';
import 'package:memox/shared/widgets/animations/fade_in_widget.dart';
import 'package:memox/shared/widgets/lists/reorderable_list.dart';

class DeckListView extends ConsumerWidget {
  const DeckListView({
    required this.decks,
    required this.onReorder,
    this.highlightedDeckId,
    super.key,
  });

  final List<DeckEntity> decks;
  final ReorderCallback onReorder;
  final int? highlightedDeckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = switch (ref.watch(allFlashcardsProvider)) {
      AsyncData<List<FlashcardEntity>>(:final value) => value,
      _ => const <FlashcardEntity>[],
    };

    return ReorderableListWidget<DeckEntity>(
      items: decks,
      onReorder: onReorder,
      itemBuilder: (context, deck, index) {
        final deckCards = cards.where((card) => card.deckId == deck.id).toList();
        final dueCards = deckCards.where(_isDue).length;
        final masteredCards = deckCards.where((card) => card.status == CardStatus.mastered).length;
        final subtitle = context.l10n.deckSubtitle(dueCards, deckCards.length);
        final mastery = deckCards.isEmpty
            ? 0.0
            : masteredCards / deckCards.length;

        return Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: FadeInWidget(
            delay: Duration(
              milliseconds: DurationTokens.staggerDelay.inMilliseconds * index,
            ),
            child: FolderDeckTile(
              deck: deck,
              subtitle: subtitle,
              masteryPercentage: mastery,
              isHighlighted: highlightedDeckId == deck.id,
            ),
          ),
        );
      },
    );
  }

  bool _isDue(FlashcardEntity card) {
    if (card.status == CardStatus.newCard) {
      return true;
    }

    return switch (card.nextReviewDate) {
      null => false,
      final nextReviewDate => !nextReviewDate.isAfter(DateTime.now()),
    };
  }
}
