import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/widgets/review_rating_button.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class ReviewRatingGrid extends StatelessWidget {
  const ReviewRatingGrid({
    required this.nextReviewTimes,
    required this.onRate,
    super.key,
  });

  final Map<ReviewRating, String> nextReviewTimes;
  final ValueChanged<ReviewRating> onRate;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.reviewRateLabel,
        style: context.textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
      const Gap.md(),
      _ReviewRatingRow(
        left: _button(context, ReviewRating.again),
        right: _button(context, ReviewRating.hard),
      ),
      const Gap.sm(),
      _ReviewRatingRow(
        left: _button(context, ReviewRating.good),
        right: _button(context, ReviewRating.easy),
      ),
    ],
  );

  ReviewRatingButton _button(BuildContext context, ReviewRating rating) =>
      ReviewRatingButton(
        rating: rating,
        label: _label(context, rating),
        hint: _hint(context, rating),
        preview: nextReviewTimes[rating] ?? '',
        onTap: () => onRate(rating),
      );

  String _label(BuildContext context, ReviewRating rating) => switch (rating) {
    ReviewRating.again => context.l10n.reviewRatingAgain,
    ReviewRating.hard => context.l10n.reviewRatingHard,
    ReviewRating.good => context.l10n.reviewRatingGood,
    ReviewRating.easy => context.l10n.reviewRatingEasy,
  };

  String _hint(BuildContext context, ReviewRating rating) => switch (rating) {
    ReviewRating.again => context.l10n.reviewRatingAgainHint,
    ReviewRating.hard => context.l10n.reviewRatingHardHint,
    ReviewRating.good => context.l10n.reviewRatingGoodHint,
    ReviewRating.easy => context.l10n.reviewRatingEasyHint,
  };
}

class _ReviewRatingRow extends StatelessWidget {
  const _ReviewRatingRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: left),
      const Gap.sm(),
      Expanded(child: right),
    ],
  );
}
