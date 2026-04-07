import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';
import 'package:memox/shared/widgets/lists/app_edit_delete_menu.dart';
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
    padding: EdgeInsets.zero,
    backgroundColor: context.colors.surfaceContainerLow,
    borderColor: context.colors.outlineVariant,
    child: ExpandableTile(
      headerPadding: const EdgeInsets.all(SpacingTokens.cardPadding),
      expandedContentPadding: const EdgeInsets.fromLTRB(
        SpacingTokens.cardPadding,
        SpacingTokens.md,
        SpacingTokens.cardPadding,
        SpacingTokens.cardPadding,
      ),
      headerBuilder: (context, {required expanded}) =>
          _CardPreviewHeader(card: card, expanded: expanded),
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.back, style: context.textTheme.bodyMedium),
          if (card.hint.isNotEmpty) ...[
            const Gap.md(),
            _CopyBlock(label: context.l10n.cardHintLabel, value: card.hint),
          ],
          if (card.example.isNotEmpty) ...[
            const Gap.md(),
            _CopyBlock(
              label: context.l10n.cardExampleLabel,
              value: card.example,
            ),
          ],
          if (card.tags.isNotEmpty) ...[
            const Gap.md(),
            Wrap(
              spacing: SpacingTokens.chipGap,
              runSpacing: SpacingTokens.chipGap,
              children: card.tags.map((tag) => TagChip(label: tag)).toList(),
            ),
          ],
          const Gap.sm(),
          Align(
            alignment: Alignment.centerRight,
            child: AppEditDeleteMenu(
              deleteLabel: context.l10n.deleteCardAction,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
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
        const Gap.xs(),
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
      const Gap.xs(),
      Text(value, style: context.textTheme.bodyMedium),
    ],
  );
}
