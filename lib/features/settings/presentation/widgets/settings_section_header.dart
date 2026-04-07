import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
    child: Text(
      label,
      style: context.textTheme.titleLarge?.copyWith(
        color: context.colors.onSurface,
      ),
    ),
  );
}
