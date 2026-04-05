import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/review_provider.dart';
import 'package:memox/features/study/presentation/widgets/review_flip_panel.dart';
import 'package:memox/features/study/presentation/widgets/review_rating_grid.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class ReviewRoundView extends StatelessWidget {
  const ReviewRoundView({
    required this.state,
    required this.onToggleFlip,
    required this.onRate,
    super.key,
  });

  final ReviewState state;
  final VoidCallback onToggleFlip;
  final ValueChanged<ReviewRating> onRate;

  @override
  Widget build(BuildContext context) {
    final card = state.currentCard;

    if (card == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.screenPadding),
      child: Column(
        children: [
          Expanded(
            child: ReviewFlipPanel(
              card: card,
              isFlipped: state.isFlipped,
              onToggleFlip: onToggleFlip,
            ),
          ),
          const Gap.xxl(),
          AnimatedSwitcher(
            duration: DurationTokens.contentSwitch,
            reverseDuration: DurationTokens.fast,
            child: state.isFlipped
                ? ReviewRatingGrid(
                    key: ValueKey<String>('review-rate-${card.id}'),
                    nextReviewTimes: state.nextReviewTimes,
                    onRate: onRate,
                  )
                : Text(
                    context.l10n.reviewTapToReveal,
                    key: ValueKey<String>('review-hint-${card.id}'),
                    style: context.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
      ),
    );
  }
}
