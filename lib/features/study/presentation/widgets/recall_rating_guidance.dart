import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class RecallRatingGuidance extends StatelessWidget {
  const RecallRatingGuidance({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _RecallRatingHint(
        label: context.l10n.recallRatingMissed,
        hint: context.l10n.recallRatingMissedHint,
      ),
      const SizedBox(height: SpacingTokens.xs),
      _RecallRatingHint(
        label: context.l10n.recallRatingPartial,
        hint: context.l10n.recallRatingPartialHint,
      ),
      const SizedBox(height: SpacingTokens.xs),
      _RecallRatingHint(
        label: context.l10n.recallRatingGotIt,
        hint: context.l10n.recallRatingGotItHint,
      ),
    ],
  );
}

class _RecallRatingHint extends StatelessWidget {
  const _RecallRatingHint({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: SpacingTokens.xs,
    children: [
      Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colors.onSurface,
        ),
      ),
      Text(
        hint,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    ],
  );
}
