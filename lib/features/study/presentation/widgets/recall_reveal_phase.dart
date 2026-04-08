import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/widgets/recall_comparison_view.dart';
import 'package:memox/features/study/presentation/widgets/recall_rating_guidance.dart';
import 'package:memox/features/study/presentation/widgets/recall_self_assessment.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';

class RecallRevealPhase extends StatelessWidget {
  const RecallRevealPhase({
    required this.card,
    required this.state,
    required this.onEditCard,
    required this.onRateSelf,
    super.key,
  });

  final FlashcardEntity card;
  final RecallState state;
  final VoidCallback onEditCard;
  final ValueChanged<SelfRating> onRateSelf;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconActionButton(
            icon: Icons.edit_outlined,
            tooltip: context.l10n.editAction,
            onTap: onEditCard,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        RecallComparisonView(
          userAnswer: state.userAnswer,
          correctAnswer: card.front,
        ),
        const SizedBox(height: SpacingTokens.fieldGap),
        RecallSelfAssessment(
          selectedRating: state.selfRating,
          onSelected: onRateSelf,
        ),
        const SizedBox(height: SpacingTokens.md),
        const RecallRatingGuidance(),
      ],
    ),
  );
}
