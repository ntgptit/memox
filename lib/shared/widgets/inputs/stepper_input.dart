import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';

class StepperInput extends StatelessWidget {
  const StepperInput({
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.step,
    required this.label,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: context.textTheme.titleSmall)),
      IconActionButton(
        icon: Icons.remove,
        onTap: value <= min
            ? null
            : () => onChanged(math.max(min, value - step)),
      ),
      const SizedBox(width: SpacingTokens.md),
      Text(value.toString(), style: context.appTextStyles.statNumberSm),
      const SizedBox(width: SpacingTokens.md),
      IconActionButton(
        icon: Icons.add,
        onTap: value >= max
            ? null
            : () => onChanged(math.min(max, value + step)),
      ),
    ],
  );
}
