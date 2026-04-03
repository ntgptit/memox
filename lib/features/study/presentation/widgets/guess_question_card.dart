import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/guess/guess_engine.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class GuessQuestionCard extends StatelessWidget {
  const GuessQuestionCard({required this.question, super.key});

  final GuessQuestion question;

  @override
  Widget build(BuildContext context) => AppCard(
    backgroundColor: context.colors.surfaceContainerHighest,
    padding: const EdgeInsets.all(SpacingTokens.fieldGap),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.guessPromptLabel,
          style: context.appTextStyles.statLabel,
        ),
        const SizedBox(height: SpacingTokens.lg),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                question.definition,
                style: context.appTextStyles.questionText,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
