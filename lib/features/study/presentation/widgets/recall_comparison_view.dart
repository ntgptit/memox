import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class RecallComparisonView extends StatelessWidget {
  const RecallComparisonView({
    required this.userAnswer,
    required this.correctAnswer,
    super.key,
  });

  final String userAnswer;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _RecallAnswerCard(
        label: context.l10n.recallYourAnswerLabel,
        text: userAnswer,
        leftBorderColor: context.colors.outline,
      ),
      const SizedBox(height: SpacingTokens.fieldGap),
      _RecallAnswerCard(
        label: context.l10n.recallCompleteAnswerLabel,
        text: correctAnswer,
        leftBorderColor: context.colors.primary,
        backgroundColor: context.colors.surfaceContainerHighest,
        maxHeight: SizeTokens.recallAnswerMaxHeight,
      ),
    ],
  );
}

class _RecallAnswerCard extends StatelessWidget {
  const _RecallAnswerCard({
    required this.label,
    required this.text,
    required this.leftBorderColor,
    this.backgroundColor,
    this.maxHeight,
  });

  final String label;
  final String text;
  final Color leftBorderColor;
  final Color? backgroundColor;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: context.textTheme.bodySmall),
      const SizedBox(height: SpacingTokens.sm),
      AppCard(
        backgroundColor: backgroundColor,
        leftBorderColor: leftBorderColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
          child: SingleChildScrollView(
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                height: TypographyTokens.relaxedHeight,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
