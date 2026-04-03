import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: context.textTheme.labelSmall?.copyWith(
      color: context.colors.onSurfaceVariant,
      fontWeight: TypographyTokens.medium,
      letterSpacing: TypographyTokens.sectionSpacing,
    ),
  );
}
