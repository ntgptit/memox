import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/features/study/presentation/widgets/fill_answer_input.dart';
import 'package:memox/features/study/presentation/widgets/fill_feedback_panel.dart';
import 'package:memox/features/study/presentation/widgets/fill_prompt_card.dart';
import 'package:memox/shared/widgets/cards/info_bar.dart';

class FillRoundView extends StatelessWidget {
  const FillRoundView({
    required this.state,
    required this.controller,
    required this.focusNode,
    required this.isNumericAnswer,
    required this.onInputChanged,
    required this.onSubmit,
    required this.onShowHint,
    required this.onAcceptClose,
    required this.onRejectClose,
    required this.onSkip,
    this.warningText,
    super.key,
  });

  final FillState state;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isNumericAnswer;
  final ValueChanged<String> onInputChanged;
  final VoidCallback onSubmit;
  final VoidCallback onShowHint;
  final VoidCallback onAcceptClose;
  final VoidCallback onRejectClose;
  final VoidCallback onSkip;
  final String? warningText;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      SpacingTokens.screenPadding,
      SpacingTokens.xl,
      SpacingTokens.screenPadding,
      SpacingTokens.screenPadding + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: AnimatedSwitcher(
      duration: DurationTokens.contentSwitch,
      child: _FillRoundContent(
        key: ValueKey<String>(state.currentCard?.id.toString() ?? 'fill-empty'),
        state: state,
        controller: controller,
        focusNode: focusNode,
        isNumericAnswer: isNumericAnswer,
        onInputChanged: onInputChanged,
        onSubmit: onSubmit,
        onShowHint: onShowHint,
        onAcceptClose: onAcceptClose,
        onRejectClose: onRejectClose,
        onSkip: onSkip,
        warningText: warningText,
      ),
    ),
  );
}

class _FillRoundContent extends StatelessWidget {
  const _FillRoundContent({
    required this.state,
    required this.controller,
    required this.focusNode,
    required this.isNumericAnswer,
    required this.onInputChanged,
    required this.onSubmit,
    required this.onShowHint,
    required this.onAcceptClose,
    required this.onRejectClose,
    required this.onSkip,
    this.warningText,
    super.key,
  });

  final FillState state;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isNumericAnswer;
  final ValueChanged<String> onInputChanged;
  final VoidCallback onSubmit;
  final VoidCallback onShowHint;
  final VoidCallback onAcceptClose;
  final VoidCallback onRejectClose;
  final VoidCallback onSkip;
  final String? warningText;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (warningText != null) ...[
        InfoBar(icon: Icons.lightbulb_outline, text: warningText!),
        const SizedBox(height: SpacingTokens.lg),
      ],
      FillPromptCard(
        prompt: state.currentPrompt,
        showHint: state.showHint,
        showAnswer: state.result == FillResult.correct,
        onShowHint: onShowHint,
      ),
      const SizedBox(height: SpacingTokens.fieldGap),
      FillAnswerInput(
        controller: controller,
        focusNode: focusNode,
        result: state.result,
        isRetrying: state.isRetrying,
        canSubmit: state.canSubmit,
        isNumericAnswer: isNumericAnswer,
        onChanged: onInputChanged,
        onSubmit: onSubmit,
      ),
      const SizedBox(height: SpacingTokens.lg),
      FillFeedbackPanel(
        result: state.result,
        answer: state.currentPrompt.correctAnswer,
        userAnswer: state.submittedAnswer ?? '',
        canSkip: state.canSkip,
        onAcceptClose: onAcceptClose,
        onRejectClose: onRejectClose,
        onSkip: onSkip,
      ),
    ],
  );
}
