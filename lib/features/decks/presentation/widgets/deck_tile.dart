import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';
import 'package:memox/shared/widgets/progress/mastery_bar.dart';

class DeckTile extends StatelessWidget {
  const DeckTile({
    required this.deck,
    required this.subtitle,
    required this.masteryPercentage,
    required this.dueCount,
    this.isHighlighted = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final DeckEntity deck;
  final String subtitle;
  final double masteryPercentage;
  final int dueCount;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(deck.colorValue);

    return AppCard(
      onTap: onTap,
      borderRadius: RadiusTokens.lg,
      borderColor: isHighlighted ? context.colors.primary : null,
      backgroundColor: context.colors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DeckGlyph(color: accentColor),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: _DeckCopy(
                  deck: deck,
                  subtitle: subtitle,
                  dueCount: dueCount,
                ),
              ),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: SpacingTokens.md),
                _DeckActions(onEdit: onEdit, onDelete: onDelete),
              ],
            ],
          ),
          if (deck.tags.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.md),
            Wrap(
              spacing: SpacingTokens.chipGap,
              runSpacing: SpacingTokens.chipGap,
              children: deck.tags.map((tag) => TagChip(label: tag)).toList(),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
          _DeckProgress(
            masteryPercentage: masteryPercentage,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class _DeckCopy extends StatelessWidget {
  const _DeckCopy({
    required this.deck,
    required this.subtitle,
    required this.dueCount,
  });

  final DeckEntity deck;
  final String subtitle;
  final int dueCount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(deck.name, style: context.textTheme.titleMedium),
          ),
          if (dueCount > 0) ...[
            const SizedBox(width: SpacingTokens.sm),
            _DuePill(count: dueCount),
          ],
        ],
      ),
      const SizedBox(height: SpacingTokens.xs),
      Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      if (deck.description.trim().isNotEmpty) ...[
        const SizedBox(height: SpacingTokens.sm),
        Text(
          deck.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium,
        ),
      ],
    ],
  );
}

class _DeckGlyph extends StatelessWidget {
  const _DeckGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: OpacityTokens.focus),
      borderRadius: BorderRadius.circular(RadiusTokens.md),
    ),
    child: SizedBox.square(
      dimension: SizeTokens.avatarLg,
      child: Icon(Icons.style_outlined, color: color),
    ),
  );
}

class _DeckActions extends StatelessWidget {
  const _DeckActions({required this.onEdit, required this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (onEdit != null)
        IconActionButton(
          icon: Icons.edit_outlined,
          tooltip: context.l10n.editAction,
          size: SizeTokens.buttonHeightSm,
          onTap: onEdit,
        ),
      if (onEdit != null && onDelete != null)
        const SizedBox(height: SpacingTokens.xs),
      if (onDelete != null)
        IconActionButton(
          icon: Icons.delete_outline,
          tooltip: context.l10n.deleteDeckAction,
          size: SizeTokens.buttonHeightSm,
          onTap: onDelete,
        ),
    ],
  );
}

class _DeckProgress extends StatelessWidget {
  const _DeckProgress({
    required this.masteryPercentage,
    required this.accentColor,
  });

  final double masteryPercentage;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: MasteryBar(percentage: masteryPercentage)),
      const SizedBox(width: SpacingTokens.md),
      Text(
        context.l10n.deckMasteryLabel((masteryPercentage * 100).round()),
        style: context.textTheme.labelMedium?.copyWith(color: accentColor),
      ),
    ],
  );
}

class _DuePill extends StatelessWidget {
  const _DuePill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.customColors.ratingHard.withValues(
        alpha: OpacityTokens.focus,
      ),
      borderRadius: BorderRadius.circular(RadiusTokens.full),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: Text(
        '$count',
        style: context.textTheme.labelMedium?.copyWith(
          color: context.customColors.ratingHard,
        ),
      ),
    ),
  );
}
