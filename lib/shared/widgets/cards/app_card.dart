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
    final radius = borderRadius ?? RadiusTokens.card;
    final outlineColor =
        borderColor ??
        Theme.of(
          context,
        ).colorScheme.outline.withValues(alpha: OpacityTokens.borderSubtle);
    final content = AnimatedOpacity(
      opacity: enabled ? 1 : OpacityTokens.disabled,
      duration: DurationTokens.fast,
      child: _AppCardSurface(
        padding: padding,
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.surface,
        outlineColor: outlineColor,
        radius: radius,
        leftBorderColor: leftBorderColor,
        child: child,
      ),
    );

    if (!enabled) {
      return content;
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
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
    required this.backgroundColor,
    required this.outlineColor,
    required this.radius,
    required this.leftBorderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color outlineColor;
  final double radius;
  final Color? leftBorderColor;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: outlineColor),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: decoration,
        child: Stack(
          children: [
            if (leftBorderColor != null)
              _AppCardAccentStripe(color: leftBorderColor!, radius: radius),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
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
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
        ),
      ),
      child: const SizedBox(width: SizeTokens.borderWidthThick),
    ),
  );
}
