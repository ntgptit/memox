import 'package:flutter/material.dart';

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
  ) => child;

  @override
  bool shouldRebuild(covariant DeckCardsToolbarDelegate oldDelegate) => child != oldDelegate.child || height != oldDelegate.height;
}
