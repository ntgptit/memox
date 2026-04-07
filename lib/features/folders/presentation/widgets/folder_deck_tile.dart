import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/shared/widgets/lists/app_card_list_tile.dart';
import 'package:memox/shared/widgets/lists/app_tile_glyph.dart';
import 'package:memox/shared/widgets/progress/mastery_ring.dart';

class FolderDeckTile extends StatelessWidget {
  const FolderDeckTile({
    required this.deck,
    required this.subtitle,
    required this.masteryPercentage,
    this.isHighlighted = false,
    this.onTap,
    super.key,
  });

  final DeckEntity deck;
  final String subtitle;
  final double masteryPercentage;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppCardListTile(
    onTap: onTap,
    borderColor: isHighlighted ? context.colors.primary : null,
    leading: AppTileGlyph(
      icon: Icons.style_outlined,
      color: Color(deck.colorValue),
    ),
    title: Text(deck.name, style: context.textTheme.titleMedium),
    subtitle: Text(
      subtitle,
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    ),
    trailing: MasteryRing(
      percentage: masteryPercentage,
      showZeroPercentText: true,
    ),
  );
}
