import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class StudyEntryConflictView extends StatelessWidget {
  const StudyEntryConflictView({
    required this.modeLabel,
    required this.deckName,
    required this.onBackToHub,
    required this.onDiscardAndStart,
    super.key,
  });

  final String modeLabel;
  final String deckName;
  final VoidCallback onBackToHub;
  final VoidCallback onDiscardAndStart;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.studyActiveSessionConflictTitle,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              context.l10n.studyActiveSessionConflictMessage(
                modeLabel,
                deckName,
              ),
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: SpacingTokens.lg),
            SecondaryButton(
              label: context.l10n.studyBackToHubAction,
              onPressed: onBackToHub,
            ),
            const SizedBox(height: SpacingTokens.sm),
            PrimaryButton(
              label: context.l10n.studyDiscardAndStartAction,
              onPressed: onDiscardAndStart,
            ),
          ],
        ),
      ),
    ),
  );
}
