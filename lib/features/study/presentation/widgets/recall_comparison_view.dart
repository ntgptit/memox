import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/presentation/widgets/recall_highlighted_text.dart';
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
  Widget build(BuildContext context) {
    final userKeywords = _keywords(userAnswer);
    final correctKeywords = _keywords(correctAnswer);
    final matching = userKeywords.intersection(correctKeywords);
    final missing = correctKeywords.difference(userKeywords);
    final extra = userKeywords.difference(correctKeywords);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecallAnswerCard(
          label: context.l10n.recallYourAnswerLabel,
          leftBorderColor: context.colors.outline,
          text: RecallHighlightedText(
            text: userAnswer,
            matchingKeywords: matching,
            emphasisKeywords: extra,
            emphasisColor: context.colors.error,
          ),
        ),
        const SizedBox(height: SpacingTokens.fieldGap),
        _RecallAnswerCard(
          label: context.l10n.recallCompleteAnswerLabel,
          leftBorderColor: context.colors.primary,
          backgroundColor: context.colors.surfaceContainerHighest,
          maxHeight: SizeTokens.recallAnswerMaxHeight,
          text: RecallHighlightedText(
            text: correctAnswer,
            matchingKeywords: matching,
            emphasisKeywords: missing,
            emphasisColor: context.colors.error,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          context.l10n.recallComparisonHint,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
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
  final Widget text;
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
          child: SingleChildScrollView(child: text),
        ),
      ),
    ],
  );
}

Set<String> _keywords(String value) => value
    .split(RegExp(r'\s+'))
    .map(_normalizeKeyword)
    .where((keyword) => keyword.isNotEmpty)
    .toSet();

String _normalizeKeyword(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[.,!?;:()\[\]{}]'), '')
    .replaceAll("'", '')
    .replaceAll('"', '')
    .replaceAll('`', '');
