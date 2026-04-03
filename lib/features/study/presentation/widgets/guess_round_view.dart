import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/widgets/guess_option_button.dart';
import 'package:memox/features/study/presentation/widgets/guess_question_card.dart';
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
  Widget build(BuildContext context) => Padding(
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
          child: GuessQuestionCard(question: state.currentQuestion),
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
  Widget build(BuildContext context) {
    final footerAction = _footerAction(context);

    return Column(
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
                      isCorrectAnswer:
                          state.isAnswered && entry.value.isCorrect,
                      isWrongSelection:
                          state.isAnswered &&
                          state.selectedOptionIndex == entry.key &&
                          state.isCorrect == false,
                      onTap: () => onSelect(entry.key),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (footerAction != null) ...[
          const SizedBox(height: SpacingTokens.sm),
          Align(alignment: Alignment.centerLeft, child: footerAction),
        ],
      ],
    );
  }

  Widget? _footerAction(BuildContext context) {
    if (state.canContinue) {
      return TextLinkButton(
        label: context.l10n.guessContinueAction,
        onTap: onContinue,
        showTrailingArrow: true,
      );
    }

    if (!state.isAnswered) {
      return TextLinkButton(
        label: context.l10n.guessSkipAction,
        onTap: onSkip,
        showTrailingArrow: true,
      );
    }

    return null;
  }
}

String _optionPrefix(BuildContext context, int index) => switch (index) {
  0 => context.l10n.guessOptionPrefixA,
  1 => context.l10n.guessOptionPrefixB,
  2 => context.l10n.guessOptionPrefixC,
  _ => context.l10n.guessOptionPrefixD,
};
