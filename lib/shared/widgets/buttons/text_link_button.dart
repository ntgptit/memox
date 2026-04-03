import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    required this.label,
    this.onTap,
    this.color,
    this.showTrailingArrow = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool showTrailingArrow;

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? context.colors.primary;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.appTextStyles.tagText.copyWith(color: accentColor),
          ),
          if (showTrailingArrow) ...[
            const SizedBox(width: SpacingTokens.xs),
            Icon(Icons.arrow_forward, color: accentColor),
          ],
        ],
      ),
    );
  }
}
