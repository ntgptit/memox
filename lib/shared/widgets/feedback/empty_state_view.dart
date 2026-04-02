import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child:
        ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: SizeTokens.emptyStateTextWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: SizeTokens.iconXl,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    title,
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: SpacingTokens.lg),
                    SecondaryButton(
                      label: actionLabel!,
                      onPressed: onAction,
                      fullWidth: false,
                    ),
                  ],
                ],
              ),
            )
            .animate()
            .fadeIn(duration: DurationTokens.slow)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: DurationTokens.slow,
            ),
  );
}
