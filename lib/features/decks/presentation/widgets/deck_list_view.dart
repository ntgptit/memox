import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';
import 'package:memox/features/decks/presentation/providers/deck_stats_provider.dart';
import 'package:memox/features/decks/presentation/widgets/deck_tile.dart';
import 'package:memox/shared/widgets/animations/fade_in_widget.dart';
import 'package:memox/shared/widgets/lists/reorderable_list.dart';

class DeckListView extends StatelessWidget {
  const DeckListView({
    required this.decks,
    required this.onReorder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onRefresh,
    this.isSortMode = false,
    this.highlightedDeckId,
    super.key,
  });

  final List<DeckEntity> decks;
  final ReorderCallback onReorder;
  final ValueChanged<DeckEntity> onTap;
  final ValueChanged<DeckEntity> onEdit;
  final ValueChanged<DeckEntity> onDelete;
  final RefreshCallback? onRefresh;
  final bool isSortMode;
  final int? highlightedDeckId;

  @override
  Widget build(BuildContext context) => ReorderableListWidget<DeckEntity>(
    items: decks,
    onReorder: onReorder,
    onRefresh: onRefresh,
    isReorderEnabled: isSortMode,
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
            final subtitle = context.l10n.deckCardsDueSubtitle(
              stats?.total ?? 0,
              stats?.due ?? 0,
            );
            final mastery = stats?.mastery ?? 0.0;
            return DeckTile(
              deck: deck,
              subtitle: subtitle,
              masteryPercentage: mastery,
              dueCount: stats?.due ?? 0,
              isHighlighted: highlightedDeckId == deck.id,
              reorderHandle: isSortMode ? reorderHandle : null,
              onTap: isSortMode ? null : () => onTap(deck),
              onEdit: isSortMode ? null : () => onEdit(deck),
              onDelete: isSortMode ? null : () => onDelete(deck),
            );
          },
        ),
      ),
    ),
  );
}
