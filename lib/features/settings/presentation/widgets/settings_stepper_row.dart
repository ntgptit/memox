import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class SettingsStepperRow extends StatelessWidget {
  const SettingsStepperRow({
    required this.title,
    required this.valueLabel,
    required this.onDecrease,
    required this.onIncrease,
    this.canDecrease = true,
    this.canIncrease = true,
    super.key,
  });

  final String title;
  final String valueLabel;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final bool canDecrease;
  final bool canIncrease;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: SizeTokens.listItemHeight),
      child: Row(
        children: [
          Expanded(
            child: _SettingsStepperLabel(title: title, value: valueLabel),
          ),
          IconActionButton(
            icon: Icons.remove_outlined,
            onTap: canDecrease ? onDecrease : null,
          ),
          const Gap.sm(),
          IconActionButton(
            icon: Icons.add_outlined,
            onTap: canIncrease ? onIncrease : null,
          ),
        ],
      ),
    ),
  );
}

class _SettingsStepperLabel extends StatelessWidget {
  const _SettingsStepperLabel({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(title, style: context.textTheme.titleMedium),
      const Gap.xs(),
      Text(value, style: context.textTheme.bodySmall),
    ],
  );
}
