import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class InfoBar extends StatelessWidget {
  const InfoBar({
    required this.icon,
    required this.text,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(RadiusTokens.sm),
    child: InkWell(
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
          ],
        ),
      ),
    ),
  );
}
