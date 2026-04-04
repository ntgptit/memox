import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class AppPressable extends StatelessWidget {
  const AppPressable({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius = RadiusTokens.full,
    this.borderRadiusGeometry,
    this.constraints,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double borderRadius;
  final BorderRadius? borderRadiusGeometry;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderRadius =
        borderRadiusGeometry ?? BorderRadius.circular(borderRadius);

    return Material(
      color: color ?? context.colors.surface.withValues(alpha: 0),
      borderRadius: resolvedBorderRadius,
      clipBehavior: clipBehavior,
      child: InkWell(
        borderRadius: resolvedBorderRadius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints:
              constraints ??
              const BoxConstraints(minHeight: SizeTokens.touchTarget),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
