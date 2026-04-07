import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';
import 'package:memox/shared/widgets/cards/stat_card.dart';

class DeckStatsGrid extends StatelessWidget {
  const DeckStatsGrid({required this.stats, super.key});

  final DeckStats stats;

  @override
  Widget build(BuildContext context) => GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.isCompact ? 2 : 4,
      mainAxisSpacing: SpacingTokens.sm,
      crossAxisSpacing: SpacingTokens.sm,
      mainAxisExtent: SizeTokens.listItemTall + SpacingTokens.xl,
    ),
    children: [
      StatCard(value: '${stats.total}', label: context.l10n.totalLabel),
      StatCard(
        value: '${stats.due}',
        label: context.l10n.dueLabel,
        valueColor: context.colors.primary,
      ),
      StatCard(value: '${stats.known}', label: context.l10n.knownLabel),
      StatCard(value: '${stats.newCards}', label: context.l10n.newLabel),
    ],
  );
}
