import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';

class FillPromptSentence extends StatelessWidget {
  const FillPromptSentence({
    required this.prompt,
    required this.showAnswer,
    super.key,
  });

  final FillPrompt prompt;
  final bool showAnswer;

  @override
  Widget build(BuildContext context) {
    final parts = prompt.sentenceWithBlank.split(fillBlankToken);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: SpacingTokens.xs,
      runSpacing: SpacingTokens.sm,
      children: [
        Text(parts.first, style: context.appTextStyles.questionText),
        _FillBlankWord(prompt: prompt, showAnswer: showAnswer),
        if (parts.length > 1)
          Text(parts.last, style: context.appTextStyles.questionText),
      ],
    );
  }
}

class _FillBlankWord extends StatelessWidget {
  const _FillBlankWord({required this.prompt, required this.showAnswer});

  final FillPrompt prompt;
  final bool showAnswer;

  @override
  Widget build(BuildContext context) {
    if (showAnswer) {
      return _FillAnswerText(answer: prompt.correctAnswer);
    }

    final width = (prompt.answerLength * SpacingTokens.lg).clamp(
      SizeTokens.fillBlankMinWidth,
      SizeTokens.fillBlankMaxWidth,
    );
    return _FillBlankPulse(width: width);
  }
}

class _FillAnswerText extends StatelessWidget {
  const _FillAnswerText({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 1, end: 1.05),
    duration: DurationTokens.slow,
    builder: (context, scale, child) => Transform.scale(
      scale: scale,
      child: child,
    ),
    child: Text(
      answer,
      style: context.textTheme.titleMedium?.copyWith(
        color: context.customColors.ratingGood,
      ),
    ),
  );
}

class _FillBlankPulse extends StatefulWidget {
  const _FillBlankPulse({required this.width});

  final double width;

  @override
  State<_FillBlankPulse> createState() => _FillBlankPulseState();
}

class _FillBlankPulseState extends State<_FillBlankPulse> {
  var _highlighted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() => _highlighted = true);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: _highlighted ? 1 : 0.6,
    duration: DurationTokens.pulse,
    curve: Curves.easeInOut,
    onEnd: _togglePulse,
    child: SizedBox(
      width: widget.width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.colors.primary,
              width: SpacingTokens.xxs,
            ),
          ),
        ),
        child: const SizedBox(height: SizeTokens.touchTarget),
      ),
    ),
  );

  void _togglePulse() {
    if (!mounted) {
      return;
    }

    setState(() => _highlighted = !_highlighted);
  }
}
