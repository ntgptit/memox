import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/presentation/widgets/fill_diff_text.dart';
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
        Text(context.l10n.fillAlmostTitle, style: context.textTheme.bodySmall),
        const SizedBox(height: SpacingTokens.sm),
        Text(answer, style: context.textTheme.titleSmall),
        const SizedBox(height: SpacingTokens.sm),
        FillDiffText(userAnswer: userAnswer, correctAnswer: answer),
        const SizedBox(height: SpacingTokens.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextLinkButton(
              label: context.l10n.fillAcceptCloseAction,
              onTap: onAcceptClose,
            ),
            const SizedBox(width: SpacingTokens.lg),
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
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(answer, style: context.textTheme.titleSmall),
        if (canSkip) ...[
          const SizedBox(height: SpacingTokens.md),
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
