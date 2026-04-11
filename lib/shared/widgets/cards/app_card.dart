import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(SpacingTokens.cardPadding),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.leftBorderColor,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final Color? leftBorderColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    final radius = borderRadius ?? RadiusTokens.card;
    final background = backgroundColor ?? cardTheme.color;
    final outlineColor =
        borderColor ??
        theme.colorScheme.outlineVariant.withValues(
          alpha: OpacityTokens.borderSubtle,
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: outlineColor),
    );
    final content = AnimatedOpacity(
      opacity: enabled ? 1 : OpacityTokens.disabled,
      duration: DurationTokens.fast,
      child: _AppCardSurface(
        padding: padding,
        radius: radius,
        leftBorderColor: leftBorderColor,
        child: child,
      ),
    );
    final hasInteraction = enabled && (onTap != null || onLongPress != null);
    final material = Material(
      color: background,
      elevation: cardTheme.elevation ?? 0,
      shape: shape,
      shadowColor: cardTheme.shadowColor,
      surfaceTintColor: cardTheme.surfaceTintColor,
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    if (!hasInteraction) {
      return material;
    }

    return Material(
      color: background,
      elevation: cardTheme.elevation ?? 0,
      shape: shape,
      shadowColor: cardTheme.shadowColor,
      surfaceTintColor: cardTheme.surfaceTintColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      ),
    );
  }
}

class _AppCardSurface extends StatelessWidget {
  const _AppCardSurface({
    required this.child,
    required this.padding,
    required this.radius,
    required this.leftBorderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? leftBorderColor;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (leftBorderColor != null)
        _AppCardAccentStripe(color: leftBorderColor!, radius: radius),
      Padding(padding: padding, child: child),
    ],
  );
}

class _AppCardAccentStripe extends StatelessWidget {
  const _AppCardAccentStripe({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    top: 0,
    bottom: 0,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 1 - OpacityTokens.hover),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
        ),
      ),
      child: const SizedBox(width: SizeTokens.borderWidthThick),
    ),
  );
}
