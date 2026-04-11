import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: SizeTokens.emptyStateTextWidth + SpacingTokens.xxxl,
        ),
        child: AppCard(
          leftBorderColor: context.colors.error,
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.error.withValues(
                    alpha: OpacityTokens.softTint,
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.input),
                ),
                child: SizedBox.square(
                  dimension: SizeTokens.iconXl,
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      size: SizeTokens.iconLg,
                      color: context.colors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                message,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: SpacingTokens.xl),
                SecondaryButton(
                  label: context.l10n.retryAction,
                  onPressed: onRetry,
                  fullWidth: false,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
