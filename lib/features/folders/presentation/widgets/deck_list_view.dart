import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';
import 'package:memox/features/decks/presentation/providers/deck_stats_provider.dart';
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
  Widget build(BuildContext context, WidgetRef ref) =>
      ReorderableListWidget<DeckEntity>(
        items: decks,
        onReorder: onReorder,
        itemBuilder: (context, deck, index, reorderHandle) => Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: FadeInWidget(
            delay: Duration(
              milliseconds: DurationTokens.staggerDelay.inMilliseconds * index,
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final statsAsync = ref.watch(deckStatsProvider(deck.id));
                final stats = switch (statsAsync) {
                  AsyncData<DeckStats>(:final value) => value,
                  _ => null,
                };

                return FolderDeckTile(
                  deck: deck,
                  subtitle: context.l10n.deckSubtitle(
                    stats?.due ?? 0,
                    stats?.total ?? 0,
                  ),
                  masteryPercentage: stats?.mastery ?? 0,
                  isHighlighted: highlightedDeckId == deck.id,
                );
              },
            ),
          ),
        ),
      );
}
