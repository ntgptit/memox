import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: context.textTheme.headlineMedium?.copyWith(
      color: context.colors.onSurface,
    ),
  );
}
