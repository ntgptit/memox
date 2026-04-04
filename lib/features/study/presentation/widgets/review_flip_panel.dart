import 'package:flutter/material.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/presentation/widgets/review_card_face.dart';
import 'package:memox/shared/widgets/animations/flip_card_widget.dart';

class ReviewFlipPanel extends StatelessWidget {
  const ReviewFlipPanel({
    required this.card,
    required this.isFlipped,
    required this.onToggleFlip,
    super.key,
  });

  final FlashcardEntity card;
  final bool isFlipped;
  final VoidCallback onToggleFlip;

  @override
  Widget build(BuildContext context) => FlipCardWidget(
    isFlipped: isFlipped,
    front: ReviewCardFace(
      key: ValueKey<String>('review-front-${card.id}'),
      text: card.front,
      onTap: onToggleFlip,
    ),
    back: ReviewCardFace(
      key: ValueKey<String>('review-back-${card.id}'),
      eyebrow: card.front,
      text: card.back,
      hint: card.hint.isEmpty ? null : card.hint,
      example: card.example.isEmpty ? null : card.example,
      onTap: onToggleFlip,
    ),
  );
}
