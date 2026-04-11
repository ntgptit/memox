import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';

class FillSubmitButton extends StatelessWidget {
  const FillSubmitButton({
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: enabled ? 1 : OpacityTokens.disabled,
    duration: DurationTokens.stateChange,
    child: AppPressable(
      color: enabled
          ? context.colors.primary
          : context.colors.surfaceContainerHighest,
      onTap: enabled ? onTap : null,
      constraints: const BoxConstraints.tightFor(
        width: SizeTokens.touchTarget,
        height: SizeTokens.touchTarget,
      ),
      child: Icon(
        Icons.arrow_forward,
        size: SizeTokens.iconSm,
        color: enabled
            ? context.colors.onPrimary
            : context.colors.onSurfaceVariant,
      ),
    ),
  );
}
