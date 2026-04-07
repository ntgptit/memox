import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';

class DeckCardsToolbarDelegate extends SliverPersistentHeaderDelegate {
  DeckCardsToolbarDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    if (!overlapsContent) {
      return child;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: OpacityTokens.borderSubtle),
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant DeckCardsToolbarDelegate oldDelegate) =>
      child != oldDelegate.child || height != oldDelegate.height;
}
