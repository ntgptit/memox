import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/inputs/app_text_field.dart';

class RecallWritingArea extends StatelessWidget {
  const RecallWritingArea({
    required this.controller,
    required this.canReveal,
    required this.onChanged,
    required this.onMarkMissed,
    required this.onReveal,
    super.key,
  });

  final TextEditingController controller;
  final bool canReveal;
  final ValueChanged<String> onChanged;
  final VoidCallback onMarkMissed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: SizeTokens.recallWritingAreaMinHeight,
        ),
        child: AppTextField(
          controller: controller,
          label: context.l10n.recallYourAnswerLabel,
          hint: context.l10n.recallAnswerHint,
          minLines: 4,
          maxLines: null,
          onChanged: onChanged,
        ),
      ),
      const SizedBox(height: SpacingTokens.fieldGap),
      AnimatedOpacity(
        opacity: canReveal ? 1 : OpacityTokens.hintText,
        duration: DurationTokens.stateChange,
        child: SecondaryButton(
          label: context.l10n.recallRevealAction,
          onPressed: canReveal ? onReveal : null,
          icon: Icons.visibility_outlined,
        ),
      ),
      const SizedBox(height: SpacingTokens.sm),
      Align(
        alignment: Alignment.centerLeft,
        child: TextLinkButton(
          label: context.l10n.recallIDontKnowAction,
          onTap: onMarkMissed,
        ),
      ),
    ],
  );
}
