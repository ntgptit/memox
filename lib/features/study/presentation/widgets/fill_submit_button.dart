import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

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
    child: Material(
      color: enabled
          ? context.colors.primaryContainer
          : context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(RadiusTokens.chip),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadiusTokens.chip),
        onTap: enabled ? onTap : null,
        child: const SizedBox(
          width: SizeTokens.touchTarget,
          height: SizeTokens.touchTarget,
          child: Icon(Icons.arrow_forward, size: SizeTokens.iconSm),
        ),
      ),
    ),
  );
}
