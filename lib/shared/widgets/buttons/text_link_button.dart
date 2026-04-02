import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/animations/scale_tap.dart';

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

    return ScaleTap(
      onTap: onTap,
      scaleDown: 0.98,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.appTextStyles.tagText.copyWith(color: accentColor),
          ),
          if (showTrailingArrow)
            Icon(
              Icons.arrow_right_alt_rounded,
              color: accentColor,
            ),
        ],
      ),
    );
  }
}
