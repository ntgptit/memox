import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';

class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    required this.label,
    this.onTap,
    this.color,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
    this.showTrailingArrow = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final bool showTrailingArrow;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.colors.onSurfaceVariant;
    var resolvedStyle = context.textTheme.labelLarge?.copyWith(
      color: resolvedColor,
    );

    if (textStyle != null) {
      resolvedStyle = textStyle!.copyWith(color: color ?? textStyle!.color);
    }

    return AppPressable(
      onTap: onTap,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: resolvedStyle),
          if (showTrailingArrow) ...[
            const SizedBox(width: SpacingTokens.xs),
            Icon(
              Icons.arrow_forward_outlined,
              color: resolvedColor,
              size: SizeTokens.iconXs,
            ),
          ],
        ],
      ),
    );
  }
}
