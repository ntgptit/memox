import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/presentation/widgets/fill_prompt_sentence.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class FillPromptCard extends StatelessWidget {
  const FillPromptCard({
    required this.prompt,
    required this.showHint,
    required this.showAnswer,
    required this.onShowHint,
    super.key,
  });

  final FillPrompt prompt;
  final bool showHint;
  final bool showAnswer;
  final VoidCallback onShowHint;

  @override
  Widget build(BuildContext context) => AppCard(
    backgroundColor: context.colors.surfaceContainerHighest,
    padding: const EdgeInsets.all(SpacingTokens.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.fillPromptLabel,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap.md(),
        FillPromptSentence(prompt: prompt, showAnswer: showAnswer),
        if (showHint && prompt.hint != null) ...[
          const Gap.md(),
          Text(
            context.l10n.fillHintValue(prompt.hint!),
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
        if (!showHint && prompt.hint != null) ...[
          const Gap.md(),
          Center(
            child: TextLinkButton(
              label: context.l10n.fillShowHintAction,
              onTap: onShowHint,
            ),
          ),
        ],
      ],
    ),
  );
}
