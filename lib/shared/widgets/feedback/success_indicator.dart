import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class SuccessIndicator extends StatelessWidget {
  const SuccessIndicator({
    this.size = SizeTokens.iconXl,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.customColors.selfGotIt;

    return Align(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(RadiusTokens.full),
          ),
          child: Icon(Icons.check_rounded, color: color, size: size / 2),
        ).animate().fadeIn(duration: DurationTokens.slow).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: DurationTokens.slow,
        ),
      ),
    );
  }
}
