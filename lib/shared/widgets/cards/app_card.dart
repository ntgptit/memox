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
        Theme.of(context).colorScheme.outline.withValues(
          alpha: OpacityTokens.borderSubtle,
        );
    final decoration = BoxDecoration(
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: outlineColor),
    );
    final content = AnimatedOpacity(
      opacity: enabled ? 1 : OpacityTokens.disabled,
      duration: DurationTokens.fast,
      child: DecoratedBox(
        decoration: leftBorderColor == null
            ? decoration
            : decoration.copyWith(
                border: Border(
                  top: BorderSide(color: outlineColor),
                  right: BorderSide(color: outlineColor),
                  bottom: BorderSide(color: outlineColor),
                  left: BorderSide(
                    color: leftBorderColor!,
                    width: SizeTokens.borderWidthThick,
                  ),
                ),
              ),
        child: Padding(padding: padding, child: child),
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
