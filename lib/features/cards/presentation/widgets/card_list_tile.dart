import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';
import 'package:memox/shared/widgets/lists/expandable_tile.dart';

class CardListTile extends StatelessWidget {
  const CardListTile({
    required this.card,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final FlashcardEntity card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => AppCard(
    borderColor: context.colors.outline.withValues(
      alpha: OpacityTokens.borderSubtle,
    ),
    child: ExpandableTile(
      headerBuilder: (context, {required expanded}) =>
          _CardPreviewHeader(card: card, expanded: expanded),
      expandedContent: Padding(
        padding: const EdgeInsets.only(top: SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.back, style: context.textTheme.bodyMedium),
            if (card.hint.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.md),
              _CopyBlock(label: context.l10n.cardHintLabel, value: card.hint),
            ],
            if (card.example.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.md),
              _CopyBlock(
                label: context.l10n.cardExampleLabel,
                value: card.example,
              ),
            ],
            if (card.tags.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.md),
              Wrap(
                spacing: SpacingTokens.chipGap,
                runSpacing: SpacingTokens.chipGap,
                children: card.tags.map((tag) => TagChip(label: tag)).toList(),
              ),
            ],
            const SizedBox(height: SpacingTokens.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: context.l10n.editAction,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: context.l10n.deleteAction,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _CardPreviewHeader extends StatelessWidget {
  const _CardPreviewHeader({required this.card, required this.expanded});

  final FlashcardEntity card;
  final bool expanded;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        card.front,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleMedium,
      ),
      if (!expanded) ...[
        const SizedBox(height: SpacingTokens.xs),
        Text(
          card.back,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    ],
  );
}

class _CopyBlock extends StatelessWidget {
  const _CopyBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.textTheme.labelLarge),
      const SizedBox(height: SpacingTokens.xs),
      Text(value, style: context.textTheme.bodyMedium),
    ],
  );
}
