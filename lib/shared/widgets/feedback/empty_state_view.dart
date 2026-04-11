import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

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
                maxWidth: SizeTokens.emptyStateTextWidth + SpacingTokens.xxxl,
              ),
              child: _EmptyStateCard(
                icon: icon,
                title: title,
                subtitle: subtitle,
                actionLabel: actionLabel,
                onAction: onAction,
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

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(SpacingTokens.xl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EmptyStateBadge(icon: icon),
        const SizedBox(height: SpacingTokens.lg),
        Text(
          title,
          style: context.textTheme.headlineMedium,
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
          const SizedBox(height: SpacingTokens.xl),
          SecondaryButton(
            label: actionLabel!,
            onPressed: onAction,
            fullWidth: false,
          ),
        ],
      ],
    ),
  );
}

class _EmptyStateBadge extends StatelessWidget {
  const _EmptyStateBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.primary.withValues(alpha: OpacityTokens.softTint),
      border: Border.all(
        color: context.colors.primary.withValues(
          alpha: OpacityTokens.borderSubtle,
        ),
      ),
      borderRadius: BorderRadius.circular(RadiusTokens.input),
    ),
    child: SizedBox.square(
      dimension: SizeTokens.iconXl,
      child: Center(
        child: Icon(
          icon,
          size: SizeTokens.iconLg,
          color: context.colors.primary,
        ),
      ),
    ),
  );
}
