import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class SettingsChoiceRow extends StatelessWidget {
  const SettingsChoiceRow({
    required this.title,
    required this.valueLabel,
    required this.onTap,
    super.key,
  });

  final String title;
  final String valueLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppPressable(
    onTap: onTap,
    borderRadius: RadiusTokens.none,
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: SizeTokens.listItemHeight),
      child: Row(
        children: [
          Expanded(
            child: _SettingsChoiceLabel(title: title, valueLabel: valueLabel),
          ),
          Icon(
            Icons.expand_more_outlined,
            color: context.colors.onSurfaceVariant,
          ),
        ],
      ),
    ),
  );
}

class _SettingsChoiceLabel extends StatelessWidget {
  const _SettingsChoiceLabel({required this.title, required this.valueLabel});

  final String title;
  final String valueLabel;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(title, style: context.textTheme.titleMedium),
      const Gap.xs(),
      Text(valueLabel, style: context.textTheme.bodySmall),
    ],
  );
}
