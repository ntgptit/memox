import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/review_provider.dart';
import 'package:memox/features/study/presentation/widgets/review_flip_panel.dart';
import 'package:memox/features/study/presentation/widgets/review_rating_grid.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
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
      padding: EdgeInsets.fromLTRB(
        context.screenType.screenPadding,
        SpacingTokens.xl,
        context.screenType.screenPadding,
        SpacingTokens.xl,
      ),
      child: Column(
        children: [
          Expanded(
            child: ReviewFlipPanel(
              card: card,
              isFlipped: state.isFlipped,
              onToggleFlip: onToggleFlip,
            ),
          ),
          const Gap.xl(),
          AnimatedSwitcher(
            duration: DurationTokens.contentSwitch,
            reverseDuration: DurationTokens.fast,
            child: state.isFlipped
                ? AppCard(
                    key: ValueKey<String>('review-rate-${card.id}'),
                    child: ReviewRatingGrid(
                      nextReviewTimes: state.nextReviewTimes,
                      onRate: onRate,
                    ),
                  )
                : AppCard(
                    key: ValueKey<String>('review-hint-${card.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.reviewTapToReveal,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap.md(),
                        PrimaryButton(
                          label: context.l10n.recallRevealAction,
                          onPressed: onToggleFlip,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
