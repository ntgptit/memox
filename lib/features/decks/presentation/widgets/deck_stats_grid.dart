import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class DeckStatsGrid extends StatelessWidget {
  const DeckStatsGrid({required this.stats, super.key});

  final DeckStats stats;

  @override
  Widget build(BuildContext context) => GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.isCompact ? 2 : 4,
      mainAxisSpacing: SpacingTokens.md,
      crossAxisSpacing: SpacingTokens.md,
      mainAxisExtent: context.isCompact
          ? SizeTokens.listItemTall + SpacingTokens.md
          : SizeTokens.listItemHeight + SpacingTokens.lg,
    ),
    children: [
      _CompactStatTile(value: '${stats.total}', label: context.l10n.totalLabel),
      _CompactStatTile(value: '${stats.due}', label: context.l10n.dueLabel),
      _CompactStatTile(value: '${stats.known}', label: context.l10n.knownLabel),
      _CompactStatTile(
        value: '${stats.newCards}',
        label: context.l10n.newLabel,
      ),
    ],
  );
}

class _CompactStatTile extends StatelessWidget {
  const _CompactStatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.md,
      vertical: SpacingTokens.xs,
    ),
    borderColor: context.colors.outline.withValues(
      alpha: OpacityTokens.borderSubtle,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: context.appTextStyles.statNumberSm),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTextStyles.statLabel,
        ),
      ],
    ),
  );
}
