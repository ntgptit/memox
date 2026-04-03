import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';

class RecallSelfAssessment extends StatelessWidget {
  const RecallSelfAssessment({
    required this.selectedRating,
    required this.onSelected,
    super.key,
  });

  final SelfRating? selectedRating;
  final ValueChanged<SelfRating> onSelected;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(context, selectedRating);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.recallSelfAssessmentLabel,
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.md),
        SegmentedButton<SelfRating>(
          segments: <ButtonSegment<SelfRating>>[
            ButtonSegment<SelfRating>(
              value: SelfRating.missed,
              label: Text(context.l10n.recallRatingMissed),
            ),
            ButtonSegment<SelfRating>(
              value: SelfRating.partial,
              label: Text(context.l10n.recallRatingPartial),
            ),
            ButtonSegment<SelfRating>(
              value: SelfRating.gotIt,
              label: Text(context.l10n.recallRatingGotIt),
            ),
          ],
          selected: {?selectedRating},
          emptySelectionAllowed: true,
          expandedInsets: EdgeInsets.zero,
          showSelectedIcon: false,
          onSelectionChanged: selectedRating == null
              ? (selection) => onSelected(selection.first)
              : null,
          style: SegmentedButton.styleFrom(
            minimumSize: const Size(0, SizeTokens.buttonHeight),
            backgroundColor: context.customColors.surfaceDim,
            foregroundColor: context.colors.onSurfaceVariant,
            selectedBackgroundColor: accentColor.withValues(
              alpha: OpacityTokens.selected,
            ),
            selectedForegroundColor: context.colors.onSurface,
            side: BorderSide(color: context.colors.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.button),
            ),
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
            overlayColor: accentColor.withValues(alpha: OpacityTokens.focus),
          ),
        ),
      ],
    );
  }
}

Color _accentColor(BuildContext context, SelfRating? rating) =>
    switch (rating) {
      SelfRating.missed => context.customColors.selfMissed,
      SelfRating.partial => context.customColors.selfPartial,
      SelfRating.gotIt => context.customColors.selfGotIt,
      null => context.colors.primary,
    };
