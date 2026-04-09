import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: SizeTokens.listItemCompact),
    child: Row(
      children: [
        Expanded(
          child: subtitle == null
              ? Text(label, style: context.textTheme.titleMedium)
              : _AppSwitchTileLabel(label: label, subtitle: subtitle!),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    ),
  );
}

class AppCardSwitchTile extends StatelessWidget {
  const AppCardSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => onChanged(!value),
    borderColor: context.colors.outlineVariant.withValues(
      alpha: OpacityTokens.borderSubtle,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
    child: AppSwitchTile(
      label: label,
      value: value,
      onChanged: onChanged,
      subtitle: subtitle,
    ),
  );
}

class _AppSwitchTileLabel extends StatelessWidget {
  const _AppSwitchTileLabel({required this.label, required this.subtitle});

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.textTheme.titleMedium),
      const Gap.xs(),
      Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    ],
  );
}
