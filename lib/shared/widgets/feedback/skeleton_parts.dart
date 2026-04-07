import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/animations/shimmer_box.dart';

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    this.width = double.infinity,
    this.height = 16,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(width: width, height: height);
}

class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({this.height = SizeTokens.listItemHeight, super.key});

  final double height;

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(height: height, borderRadius: RadiusTokens.card);
}

class SkeletonHeader extends StatelessWidget {
  const SkeletonHeader({
    this.titleWidth = 200,
    this.subtitleWidth = 140,
    this.showProgressBar = false,
    super.key,
  });

  static const _loadingContentCodeUnits = <int>[
    76,
    111,
    97,
    100,
    105,
    110,
    103,
    32,
    99,
    111,
    110,
    116,
    101,
    110,
    116,
  ];

  final double titleWidth;
  final double subtitleWidth;
  final bool showProgressBar;

  @override
  Widget build(BuildContext context) => Semantics(
    label: String.fromCharCodes(_loadingContentCodeUnits),
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: titleWidth, height: SizeTokens.skeletonTitleHeight),
          const SizedBox(height: SpacingTokens.sm),
          ShimmerBox(width: subtitleWidth, height: SizeTokens.iconXs),
          if (showProgressBar) const SizedBox(height: SpacingTokens.lg),
          if (showProgressBar)
            const ShimmerBox(
              height: SizeTokens.masteryBarHeight,
              borderRadius: RadiusTokens.full,
            ),
        ],
      ),
    ),
  );
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    this.itemCount = 6,
    this.itemHeight = SizeTokens.listItemHeight,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Column(
      children: [
        for (var index = 0; index < itemCount; index++) ...[
          SkeletonListItem(height: itemHeight),
          if (index < itemCount - 1) const SizedBox(height: SpacingTokens.sm),
        ],
      ],
    ),
  );
}
