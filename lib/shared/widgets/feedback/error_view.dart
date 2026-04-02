import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: SizeTokens.iconXl,
            color: context.customColors.ratingAgain,
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            message,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: SpacingTokens.lg),
            SecondaryButton(
              label: AppStrings.retryAction,
              onPressed: onRetry,
              fullWidth: false,
            ),
          ],
        ],
      ),
    ),
  );
}
