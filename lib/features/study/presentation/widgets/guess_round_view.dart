import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/widgets/guess_feedback_card.dart';
import 'package:memox/features/study/presentation/widgets/guess_option_button.dart';
import 'package:memox/features/study/presentation/widgets/guess_question_card.dart';
import 'package:memox/shared/widgets/buttons/app_tap_region.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';

class GuessRoundView extends StatelessWidget {
  const GuessRoundView({
    required this.state,
    required this.onSelect,
    required this.onSkip,
    required this.onContinue,
    super.key,
  });

  final GuessState state;
  final ValueChanged<int> onSelect;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => AppTapRegion(
    onTap: state.isAnswered ? onContinue : null,
    behavior: HitTestBehavior.translucent,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.screenPadding,
        SpacingTokens.xl,
        SpacingTokens.screenPadding,
        SpacingTokens.screenPadding,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: GuessQuestionCard(
              question: state.currentQuestion,
              warning: state.totalCards < 8
                  ? context.l10n.guessSmallDeckWarning(state.totalCards)
                  : null,
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Expanded(
            flex: 6,
            child: _GuessAnswerArea(
              state: state,
              onSelect: onSelect,
              onSkip: onSkip,
              onContinue: onContinue,
            ),
          ),
        ],
      ),
    ),
  );
}

class _GuessAnswerArea extends StatelessWidget {
  const _GuessAnswerArea({
    required this.state,
    required this.onSelect,
    required this.onSkip,
    required this.onContinue,
  });

  final GuessState state;
  final ValueChanged<int> onSelect;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...state.currentQuestion.options.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                  child: GuessOptionButton(
                    option: entry.value,
                    prefixLabel: _optionPrefix(context, entry.key),
                    isAnswered: state.isAnswered,
                    isSelected: state.selectedOptionIndex == entry.key,
                    isCorrectAnswer: state.isAnswered && entry.value.isCorrect,
                    isWrongSelection:
                        state.isAnswered &&
                        state.selectedOptionIndex == entry.key &&
                        state.isCorrect == false,
                    onTap: () => onSelect(entry.key),
                  ),
                ),
              ),
              if (state.isAnswered && state.isCorrect == false) ...[
                const SizedBox(height: SpacingTokens.md),
                _GuessExplanationCard(state: state),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: SpacingTokens.sm),
      Align(
        alignment: Alignment.centerLeft,
        child: _GuessFooterAction(
          state: state,
          currentSkipCount: state.currentSkipCount,
          onSkip: onSkip,
          onContinue: onContinue,
        ),
      ),
    ],
  );
}

class _GuessFooterAction extends StatelessWidget {
  const _GuessFooterAction({
    required this.state,
    required this.currentSkipCount,
    required this.onSkip,
    required this.onContinue,
  });

  final GuessState state;
  final int currentSkipCount;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (state.isAnswered) {
      return TextLinkButton(
        label: context.l10n.guessContinueAction,
        onTap: onContinue,
        showTrailingArrow: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextLinkButton(
          label: context.l10n.guessSkipAction,
          onTap: onSkip,
          showTrailingArrow: true,
        ),
        if (currentSkipCount > 0)
          Text(
            context.l10n.guessSkipLimitHint(
              currentSkipCount,
              GuessStateX.skipLimit,
            ),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _GuessExplanationCard extends StatelessWidget {
  const _GuessExplanationCard({required this.state});

  final GuessState state;

  @override
  Widget build(BuildContext context) {
    final card = state.currentCard;

    if (card == null) {
      return const SizedBox.shrink();
    }

    return GuessFeedbackCard(card: card);
  }
}

String _optionPrefix(BuildContext context, int index) => switch (index) {
  0 => context.l10n.guessOptionPrefixA,
  1 => context.l10n.guessOptionPrefixB,
  2 => context.l10n.guessOptionPrefixC,
  _ => context.l10n.guessOptionPrefixD,
};
