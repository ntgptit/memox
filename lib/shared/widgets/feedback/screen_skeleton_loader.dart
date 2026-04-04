import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/feedback/shimmer_box.dart';

/// A skeleton placeholder that mimics a detail screen layout
/// while real data is still loading.
///
/// Shows shimmering boxes in the shape of a typical detail
/// screen: title, subtitle, stat chips, and a list of items.
class ScreenSkeletonLoader extends StatelessWidget {
  const ScreenSkeletonLoader({
    this.showHeader = true,
    this.itemCount = 5,
    super.key,
  });

  final bool showHeader;
  final int itemCount;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) const _SkeletonHeader(),
        if (showHeader) const SizedBox(height: SpacingTokens.sectionGap),
        ...List.generate(
          itemCount,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: SpacingTokens.sm),
            child: _SkeletonListItem(),
          ),
        ),
      ],
    ),
  );
}

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: SpacingTokens.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(
          width: SizeTokens.skeletonTitleWidth,
          height: SizeTokens.skeletonTitleHeight,
        ),
        SizedBox(height: SpacingTokens.sm),
        ShimmerBox(
          width: SizeTokens.skeletonSubtitleWidth,
          height: SizeTokens.skeletonSubtitleHeight,
        ),
        SizedBox(height: SpacingTokens.lg),
        Row(
          children: [
            ShimmerBox(
              width: SizeTokens.skeletonChipWidth,
              height: SizeTokens.chipHeight,
              borderRadius: RadiusTokens.chip,
            ),
            SizedBox(width: SpacingTokens.sm),
            ShimmerBox(
              width: SizeTokens.skeletonChipWidth,
              height: SizeTokens.chipHeight,
              borderRadius: RadiusTokens.chip,
            ),
            SizedBox(width: SpacingTokens.sm),
            ShimmerBox(
              width: SizeTokens.skeletonChipWidth,
              height: SizeTokens.chipHeight,
              borderRadius: RadiusTokens.chip,
            ),
          ],
        ),
        SizedBox(height: SpacingTokens.lg),
        ShimmerBox(height: SizeTokens.masteryBarHeight),
      ],
    ),
  );
}

class _SkeletonListItem extends StatelessWidget {
  const _SkeletonListItem();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: SizeTokens.listItemHeight,
    child: Row(
      children: [
        ShimmerBox(
          width: SizeTokens.avatarLg,
          height: SizeTokens.avatarLg,
          borderRadius: RadiusTokens.sm,
        ),
        SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: SizeTokens.skeletonSubtitleHeight),
              SizedBox(height: SpacingTokens.sm),
              ShimmerBox(
                width: SizeTokens.skeletonBodyLineWidth,
                height: SizeTokens.skeletonBodyLineHeight,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
