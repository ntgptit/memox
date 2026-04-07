import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/presentation/widgets/fill_diff_text.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class FillFeedbackPanel extends StatelessWidget {
  const FillFeedbackPanel({
    required this.result,
    required this.answer,
    required this.userAnswer,
    required this.canSkip,
    required this.onAcceptClose,
    required this.onRejectClose,
    required this.onSkip,
    super.key,
  });

  final FillResult? result;
  final String answer;
  final String userAnswer;
  final bool canSkip;
  final VoidCallback onAcceptClose;
  final VoidCallback onRejectClose;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    if (result == FillResult.close) {
      return _FillCloseFeedback(
        answer: answer,
        userAnswer: userAnswer,
        onAcceptClose: onAcceptClose,
        onRejectClose: onRejectClose,
      );
    }

    if (result != FillResult.wrong) {
      return const SizedBox.shrink();
    }

    return _FillWrongFeedback(answer: answer, canSkip: canSkip, onSkip: onSkip);
  }
}

class _FillCloseFeedback extends StatelessWidget {
  const _FillCloseFeedback({
    required this.answer,
    required this.userAnswer,
    required this.onAcceptClose,
    required this.onRejectClose,
  });

  final String answer;
  final String userAnswer;
  final VoidCallback onAcceptClose;
  final VoidCallback onRejectClose;

  @override
  Widget build(BuildContext context) => AppCard(
    leftBorderColor: context.customColors.ratingHard,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.fillAlmostTitle,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.customColors.ratingHard,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          answer,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        FillDiffText(userAnswer: userAnswer, correctAnswer: answer),
        const SizedBox(height: SpacingTokens.lg),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: SpacingTokens.buttonGap,
          runSpacing: SpacingTokens.sm,
          children: [
            SecondaryButton(
              label: context.l10n.fillAcceptCloseAction,
              onPressed: onAcceptClose,
              fullWidth: false,
              color: context.colors.primary,
            ),
            TextLinkButton(
              label: context.l10n.fillRejectCloseAction,
              onTap: onRejectClose,
            ),
          ],
        ),
      ],
    ),
  );
}

class _FillWrongFeedback extends StatelessWidget {
  const _FillWrongFeedback({
    required this.answer,
    required this.canSkip,
    required this.onSkip,
  });

  final String answer;
  final bool canSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => AppCard(
    leftBorderColor: context.customColors.ratingAgain,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.fillCorrectAnswerTitle,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colors.error,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          answer,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.onSurface,
          ),
        ),
        if (canSkip) ...[
          const SizedBox(height: SpacingTokens.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLinkButton(
              label: context.l10n.fillSkipAction,
              onTap: onSkip,
            ),
          ),
        ],
      ],
    ),
  );
}
