import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

enum AppListTileVariant { standard, sheet, search }

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = false,
    this.variant = AppListTileVariant.standard,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final AppListTileVariant variant;

  @override
  Widget build(BuildContext context) {
    final metrics = _AppListTileMetrics.resolve(
      variant: variant,
      hasSubtitle: subtitle != null,
    );
    final tile = Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: metrics.minHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: metrics.verticalPadding),
            child: Row(
              children: [
                if (leading != null) ...[
                  SizedBox.square(
                    dimension: metrics.leadingSize,
                    child: Center(child: leading),
                  ),
                  const SizedBox(width: SpacingTokens.lg),
                ],
                Expanded(
                  child: _TitleBlock(
                    title: title,
                    subtitle: subtitle,
                    variant: variant,
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: metrics.trailingGap),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (!showDivider) return tile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Divider(
          height: SizeTokens.dividerThickness,
          indent: leading == null ? 0 : metrics.leadingSize + SpacingTokens.lg,
          color: context.colors.outline.withValues(
            alpha: OpacityTokens.divider,
          ),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.title,
    required this.subtitle,
    required this.variant,
  });

  final String title;
  final String? subtitle;
  final AppListTileVariant variant;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: _titleStyle(context)),
      if (subtitle != null) ...[
        const SizedBox(height: SpacingTokens.xs),
        Text(subtitle!, style: context.textTheme.bodySmall),
      ],
    ],
  );

  TextStyle? _titleStyle(BuildContext context) => switch (variant) {
    AppListTileVariant.search => context.textTheme.titleSmall,
    AppListTileVariant.sheet => context.textTheme.titleMedium,
    AppListTileVariant.standard => context.textTheme.titleMedium,
  };
}

class _AppListTileMetrics {
  const _AppListTileMetrics({
    required this.minHeight,
    required this.verticalPadding,
    required this.leadingSize,
    required this.trailingGap,
  });

  factory _AppListTileMetrics.resolve({
    required AppListTileVariant variant,
    required bool hasSubtitle,
  }) => _AppListTileMetrics(
    minHeight: _minHeight(variant: variant, hasSubtitle: hasSubtitle),
    verticalPadding: _verticalPadding(variant),
    leadingSize: _leadingSize(variant),
    trailingGap: _trailingGap(variant),
  );

  final double minHeight;
  final double verticalPadding;
  final double leadingSize;
  final double trailingGap;

  static double _minHeight({
    required AppListTileVariant variant,
    required bool hasSubtitle,
  }) => switch ((variant, hasSubtitle)) {
    (AppListTileVariant.search, false) => SizeTokens.listItemCompact,
    (AppListTileVariant.search, true) => SizeTokens.listItemHeight,
    (AppListTileVariant.sheet, false) => SizeTokens.listItemHeight,
    (AppListTileVariant.sheet, true) =>
      SizeTokens.listItemHeight + SpacingTokens.sm,
    (_, false) => SizeTokens.listItemHeight,
    (_, true) => SizeTokens.listItemTall,
  };

  static double _verticalPadding(AppListTileVariant variant) =>
      switch (variant) {
        AppListTileVariant.search => SpacingTokens.xs,
        AppListTileVariant.sheet => SpacingTokens.sm,
        AppListTileVariant.standard => SpacingTokens.sm,
      };

  static double _leadingSize(AppListTileVariant variant) => switch (variant) {
    AppListTileVariant.search => SizeTokens.avatarMd,
    AppListTileVariant.sheet => SizeTokens.avatarLg,
    AppListTileVariant.standard => SizeTokens.avatarLg,
  };

  static double _trailingGap(AppListTileVariant variant) => switch (variant) {
    AppListTileVariant.search => SpacingTokens.sm,
    AppListTileVariant.sheet => SpacingTokens.sm,
    AppListTileVariant.standard => SpacingTokens.md,
  };
}
