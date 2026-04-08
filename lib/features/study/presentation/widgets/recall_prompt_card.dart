import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/support/flashcard_flags.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class RecallPromptCard extends StatelessWidget {
  const RecallPromptCard({required this.card, super.key});

  final FlashcardEntity card;

  @override
  Widget build(BuildContext context) {
    final visibleTags = card.visibleTags;
    final firstVisibleTag = visibleTags.isEmpty ? null : visibleTags.first;

    return AppCard(
          backgroundColor: context.colors.surfaceContainerHigh,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.recallPromptLabel,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap.sm(),
                Text(
                  card.back,
                  style: _promptStyle(context),
                  textAlign: TextAlign.center,
                ),
                if (firstVisibleTag != null) ...[
                  const Gap.md(),
                  TagChip(label: firstVisibleTag),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: DurationTokens.normal)
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          duration: DurationTokens.normal,
        );
  }

  TextStyle _promptStyle(BuildContext context) {
    final contentLength = card.back.length;

    if (contentLength > 60) {
      return context.appTextStyles.questionText;
    }

    if (contentLength > 30) {
      return context.textTheme.headlineMedium ??
          context.appTextStyles.questionText;
    }

    return context.appTextStyles.recallTerm;
  }
}
