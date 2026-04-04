import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class ReviewRatingButton extends StatelessWidget {
  const ReviewRatingButton({
    required this.rating,
    required this.label,
    required this.preview,
    required this.onTap,
    super.key,
  });

  final ReviewRating rating;
  final String label;
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(context);
    return AppCard(
      key: ValueKey<ReviewRating>(rating),
      onTap: onTap,
      backgroundColor: accentColor.withValues(alpha: OpacityTokens.selected),
      borderColor: accentColor,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: context.textTheme.titleSmall),
          Text(
            preview,
            style: context.appTextStyles.nextReviewTime.copyWith(
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _accentColor(BuildContext context) => switch (rating) {
    ReviewRating.again => context.customColors.ratingAgain,
    ReviewRating.hard => context.customColors.ratingHard,
    ReviewRating.good => context.customColors.ratingGood,
    ReviewRating.easy => context.customColors.ratingEasy,
  };
}
