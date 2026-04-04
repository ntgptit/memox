import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/presentation/widgets/deck_tile_due_pill.dart';
import 'package:memox/features/decks/presentation/widgets/deck_tile_supporting.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';
import 'package:memox/shared/widgets/lists/app_card_list_tile.dart';
import 'package:memox/shared/widgets/lists/app_edit_delete_menu.dart';
import 'package:memox/shared/widgets/lists/app_tile_glyph.dart';

class DeckTile extends StatelessWidget {
  const DeckTile({
    required this.deck,
    required this.subtitle,
    required this.masteryPercentage,
    required this.dueCount,
    this.isHighlighted = false,
    this.reorderHandle,
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
  final Widget? reorderHandle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(deck.colorValue);

    return AppCardListTile(
      onTap: onTap,
      borderColor: isHighlighted ? context.colors.primary : null,
      leading: AppTileGlyph(icon: Icons.style_outlined, color: accentColor),
      title: Text(deck.name, style: context.textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      trailing: _DeckTrailing(
        dueCount: dueCount,
        reorderHandle: reorderHandle,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
      supporting: DeckTileSupporting(
        deck: deck,
        masteryPercentage: masteryPercentage,
        accentColor: accentColor,
      ),
    );
  }
}

class _DeckTrailing extends StatelessWidget {
  const _DeckTrailing({
    required this.dueCount,
    this.reorderHandle,
    this.onEdit,
    this.onDelete,
  });

  final int dueCount;
  final Widget? reorderHandle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (dueCount == 0 &&
        reorderHandle == null &&
        onEdit == null &&
        onDelete == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dueCount > 0) DeckTileDuePill(count: dueCount),
        if (onEdit != null || onDelete != null) ...[
          if (dueCount > 0) const Gap.sm(),
          AppEditDeleteMenu(
            deleteLabel: context.l10n.deleteDeckAction,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
        if (reorderHandle != null &&
            (dueCount > 0 || onEdit != null || onDelete != null))
          const Gap.sm(),
        switch (reorderHandle) {
          final handle? => handle,
          null => const SizedBox.shrink(),
        },
      ],
    );
  }
}
