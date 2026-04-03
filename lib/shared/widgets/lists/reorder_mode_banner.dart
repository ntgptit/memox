import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class ReorderModeBanner extends StatelessWidget {
  const ReorderModeBanner({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => AppCard(
    backgroundColor: context.colors.surfaceContainerLow,
    borderColor: context.colors.primary.withValues(
      alpha: OpacityTokens.borderSubtle,
    ),
    child: Row(
      children: [
        Icon(Icons.drag_indicator_outlined, color: context.colors.primary),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Text(
            context.l10n.reorderModeHint,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.md),
        SecondaryButton(
          label: context.l10n.doneAction,
          icon: Icons.done_outline,
          fullWidth: false,
          height: SizeTokens.buttonHeightSm,
          onPressed: onDone,
        ),
      ],
    ),
  );
}
