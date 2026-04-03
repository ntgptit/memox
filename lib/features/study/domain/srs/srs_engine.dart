import 'dart:math' as math;

import 'package:memox/core/design/card_status.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

typedef CardEntity = FlashcardEntity;
typedef SRSResult = ({
  double newEaseFactor,
  int newInterval,
  int newRepetitions,
  DateTime nextReviewDate,
  CardStatus newStatus,
});

enum ReviewRating { again, hard, good, easy }

enum SelfRating { missed, partial, gotIt }

final class SRSEngine {
  SRSEngine({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const String _lessThanMinuteLabel = '< 1m';
  static const int _minimumEaseFactorTenths = 13;
  static const int _againPreviewSeconds = 30;
  static const int _hardPreviewMinutes = 10;
  static const int _secondsPerMinute = 60;
  static const int _minutesPerHour = 60;
  static const int _hoursPerDay = 24;
  static const int _daysPerMonth = 30;
  static const int _daysPerYear = 365;

  final DateTime Function() _now;

  SRSResult processReview(CardEntity card, ReviewRating rating) {
    final now = _now();
    return _processReviewAt(card, rating, now);
  }

  Map<ReviewRating, String> getNextReviewTimes(CardEntity card) {
    final now = _now();
    return <ReviewRating, String>{
      for (final rating in ReviewRating.values)
        rating: _formatDuration(_previewDuration(card, rating, now)),
    };
  }

  SRSResult processRecallSelfRating(CardEntity card, SelfRating rating) =>
      processReview(card, _reviewRatingForSelfRating(rating));

  SRSResult processFillResult(CardEntity card, {required bool isCorrect}) =>
      processReview(card, isCorrect ? ReviewRating.good : ReviewRating.again);

  SRSResult processGuessResult(CardEntity card, {required bool isCorrect}) =>
      processReview(card, isCorrect ? ReviewRating.good : ReviewRating.again);

  SRSResult processMatchResult(CardEntity card, int attempts) {
    if (attempts <= 1) {
      return processReview(card, ReviewRating.easy);
    }

    if (attempts == 2) {
      return processReview(card, ReviewRating.good);
    }

    return processReview(card, ReviewRating.hard);
  }

  SRSResult _processReviewAt(
    CardEntity card,
    ReviewRating rating,
    DateTime now,
  ) {
    final quality = _qualityForRating(rating);
    final newRepetitions = _nextRepetitions(card.repetitions, quality);
    final newInterval = _nextInterval(
      previousInterval: card.interval,
      previousEaseFactor: card.easeFactor,
      newRepetitions: newRepetitions,
      quality: quality,
    );
    final newEaseFactor = _nextEaseFactor(card.easeFactor, quality);
    final newStatus = _nextStatus(
      previousStatus: card.status,
      quality: quality,
      newRepetitions: newRepetitions,
      newEaseFactor: newEaseFactor,
      newInterval: newInterval,
    );

    return (
      newEaseFactor: newEaseFactor,
      newInterval: newInterval,
      newRepetitions: newRepetitions,
      nextReviewDate: now.add(Duration(days: newInterval)),
      newStatus: newStatus,
    );
  }

  Duration _previewDuration(
    CardEntity card,
    ReviewRating rating,
    DateTime now,
  ) {
    final earlyLearningDuration = _earlyLearningPreviewDuration(card, rating);
    if (earlyLearningDuration != null) {
      return earlyLearningDuration;
    }

    final result = _processReviewAt(card, rating, now);
    return result.nextReviewDate.difference(now);
  }

  Duration? _earlyLearningPreviewDuration(
    CardEntity card,
    ReviewRating rating,
  ) {
    final isEarlyLearning =
        card.status == CardStatus.newCard || card.status == CardStatus.learning;

    if (!isEarlyLearning) {
      return null;
    }

    if (rating == ReviewRating.again) {
      return const Duration(seconds: _againPreviewSeconds);
    }

    if (rating == ReviewRating.hard) {
      return const Duration(minutes: _hardPreviewMinutes);
    }

    return null;
  }

  ReviewRating _reviewRatingForSelfRating(SelfRating rating) =>
      switch (rating) {
        SelfRating.missed => ReviewRating.again,
        SelfRating.partial => ReviewRating.hard,
        SelfRating.gotIt => ReviewRating.good,
      };

  int _qualityForRating(ReviewRating rating) => switch (rating) {
    ReviewRating.again => 0,
    ReviewRating.hard => 2,
    ReviewRating.good => 3,
    ReviewRating.easy => 5,
  };

  int _nextRepetitions(int previousRepetitions, int quality) {
    if (quality < 3) {
      return 0;
    }

    return previousRepetitions + 1;
  }

  int _nextInterval({
    required int previousInterval,
    required double previousEaseFactor,
    required int newRepetitions,
    required int quality,
  }) {
    if (quality < 3) {
      return 1;
    }

    if (newRepetitions == 1) {
      return 1;
    }

    if (newRepetitions == 2) {
      return 6;
    }

    return math.max(1, (previousInterval * previousEaseFactor).round());
  }

  double _nextEaseFactor(double previousEaseFactor, int quality) {
    if (quality < 3) {
      return previousEaseFactor;
    }

    final qualityDistance = 5 - quality;
    final updatedEaseFactor =
        previousEaseFactor +
        (0.1 - qualityDistance * (0.08 + qualityDistance * 0.02));
    const minimumEaseFactor = _minimumEaseFactorTenths / 10;
    return math.max(minimumEaseFactor, updatedEaseFactor);
  }

  CardStatus _nextStatus({
    required CardStatus previousStatus,
    required int quality,
    required int newRepetitions,
    required double newEaseFactor,
    required int newInterval,
  }) {
    if (quality == 0) {
      return CardStatus.learning;
    }

    if (previousStatus == CardStatus.mastered && quality < 3) {
      return CardStatus.reviewing;
    }

    if (quality < 3) {
      return CardStatus.learning;
    }

    if (previousStatus == CardStatus.newCard) {
      return CardStatus.learning;
    }

    if (previousStatus == CardStatus.learning && newRepetitions >= 2) {
      return CardStatus.reviewing;
    }

    if (previousStatus == CardStatus.reviewing &&
        newEaseFactor > 2.5 &&
        newInterval > 21) {
      return CardStatus.mastered;
    }

    if (previousStatus == CardStatus.mastered) {
      return CardStatus.mastered;
    }

    return previousStatus;
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < _secondsPerMinute) {
      return _lessThanMinuteLabel;
    }

    if (duration.inMinutes < _minutesPerHour) {
      return '${duration.inMinutes}m';
    }

    if (duration.inHours < _hoursPerDay) {
      return '${duration.inHours}h';
    }

    if (duration.inDays < _daysPerMonth) {
      return '${duration.inDays}d';
    }

    if (duration.inDays < _daysPerYear) {
      return '${(duration.inDays / _daysPerMonth).round()}mo';
    }

    return '${(duration.inDays / _daysPerYear).round()}y';
  }
}
