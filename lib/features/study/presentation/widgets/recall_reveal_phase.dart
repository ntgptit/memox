import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/widgets/recall_comparison_view.dart';
import 'package:memox/features/study/presentation/widgets/recall_self_assessment.dart';

class RecallRevealPhase extends StatelessWidget {
  const RecallRevealPhase({
    required this.card,
    required this.state,
    required this.onRateSelf,
    super.key,
  });

  final FlashcardEntity card;
  final RecallState state;
  final ValueChanged<SelfRating> onRateSelf;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RecallComparisonView(
          userAnswer: state.userAnswer,
          correctAnswer: card.back,
        ),
        const SizedBox(height: SpacingTokens.fieldGap),
        RecallSelfAssessment(
          selectedRating: state.selfRating,
          onSelected: onRateSelf,
        ),
      ],
    ),
  );
}
