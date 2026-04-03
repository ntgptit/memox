import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';

void main() {
  final fixedNow = DateTime(2026, 4, 3, 9);
  final engine = SRSEngine(now: () => fixedNow);

  group('processReview', () {
    test('again resets repetitions and schedules tomorrow as learning', () {
      final result = engine.processReview(
        _card(status: CardStatus.reviewing, interval: 12, repetitions: 4),
        ReviewRating.again,
      );

      expect(result.newEaseFactor, 2.5);
      expect(result.newInterval, 1);
      expect(result.newRepetitions, 0);
      expect(result.nextReviewDate, fixedNow.add(const Duration(days: 1)));
      expect(result.newStatus, CardStatus.learning);
    });

    test(
      'hard uses the low-quality path and keeps the current ease factor',
      () {
        final result = engine.processReview(
          _card(
            status: CardStatus.reviewing,
            interval: 18,
            repetitions: 5,
            easeFactor: 2.3,
          ),
          ReviewRating.hard,
        );

        expect(result.newEaseFactor, 2.3);
        expect(result.newInterval, 1);
        expect(result.newRepetitions, 0);
        expect(result.newStatus, CardStatus.learning);
      },
    );

    test('good on first review schedules one day and keeps card learning', () {
      final result = engine.processReview(_card(), ReviewRating.good);

      expect(result.newEaseFactor, closeTo(2.36, 0.0001));
      expect(result.newInterval, 1);
      expect(result.newRepetitions, 1);
      expect(result.newStatus, CardStatus.learning);
    });

    test(
      'second consecutive correct review moves learning card to reviewing',
      () {
        final result = engine.processReview(
          _card(
            status: CardStatus.learning,
            interval: 1,
            repetitions: 1,
            easeFactor: 2.36,
          ),
          ReviewRating.good,
        );

        expect(result.newInterval, 6);
        expect(result.newRepetitions, 2);
        expect(result.newStatus, CardStatus.reviewing);
      },
    );

    test(
      'easy grows interval from the previous interval after repetition two',
      () {
        final result = engine.processReview(
          _card(status: CardStatus.reviewing, interval: 6, repetitions: 2),
          ReviewRating.easy,
        );

        expect(result.newEaseFactor, closeTo(2.6, 0.0001));
        expect(result.newInterval, 15);
        expect(result.newRepetitions, 3);
        expect(result.newStatus, CardStatus.reviewing);
      },
    );
  });

  group('status transitions', () {
    test(
      'reviewing card becomes mastered after long interval and high ease',
      () {
        final result = engine.processReview(
          _card(
            status: CardStatus.reviewing,
            interval: 10,
            repetitions: 4,
            easeFactor: 2.6,
          ),
          ReviewRating.easy,
        );

        expect(result.newInterval, 26);
        expect(result.newStatus, CardStatus.mastered);
      },
    );

    test('mastered card downgrades to reviewing on hard', () {
      final result = engine.processReview(
        _card(
          status: CardStatus.mastered,
          interval: 30,
          repetitions: 7,
          easeFactor: 2.8,
        ),
        ReviewRating.hard,
      );

      expect(result.newRepetitions, 0);
      expect(result.newInterval, 1);
      expect(result.newStatus, CardStatus.reviewing);
    });

    test('again always forces learning even from mastered', () {
      final result = engine.processReview(
        _card(
          status: CardStatus.mastered,
          interval: 40,
          repetitions: 8,
          easeFactor: 2.9,
        ),
        ReviewRating.again,
      );

      expect(result.newStatus, CardStatus.learning);
    });
  });

  group('edge cases', () {
    test('ease factor never drops below the minimum value', () {
      final result = engine.processReview(
        _card(
          status: CardStatus.reviewing,
          interval: 6,
          repetitions: 2,
          easeFactor: 1.31,
        ),
        ReviewRating.good,
      );

      expect(result.newEaseFactor, 1.3);
    });

    test('long intervals round using the previous ease factor', () {
      final result = engine.processReview(
        _card(
          status: CardStatus.reviewing,
          interval: 100,
          repetitions: 5,
          easeFactor: 2.8,
        ),
        ReviewRating.easy,
      );

      expect(result.newInterval, 280);
      expect(result.nextReviewDate, fixedNow.add(const Duration(days: 280)));
    });
  });

  group('rating adapters', () {
    test('recall partial maps to hard review processing', () {
      final card = _card(
        status: CardStatus.learning,
        interval: 1,
        repetitions: 1,
      );

      expect(
        engine.processRecallSelfRating(card, SelfRating.partial),
        engine.processReview(card, ReviewRating.hard),
      );
    });

    test('fill correct maps to good review processing', () {
      final card = _card(
        status: CardStatus.learning,
        interval: 1,
        repetitions: 1,
      );

      expect(
        engine.processFillResult(card, isCorrect: true),
        engine.processReview(card, ReviewRating.good),
      );
    });

    test('guess wrong maps to again review processing', () {
      final card = _card(
        status: CardStatus.reviewing,
        interval: 7,
        repetitions: 3,
      );

      expect(
        engine.processGuessResult(card, isCorrect: false),
        engine.processReview(card, ReviewRating.again),
      );
    });

    test('match attempts map to easy, good, and hard', () {
      final card = _card(
        status: CardStatus.reviewing,
        interval: 6,
        repetitions: 2,
      );

      expect(
        engine.processMatchResult(card, 1),
        engine.processReview(card, ReviewRating.easy),
      );
      expect(
        engine.processMatchResult(card, 2),
        engine.processReview(card, ReviewRating.good),
      );
      expect(
        engine.processMatchResult(card, 3),
        engine.processReview(card, ReviewRating.hard),
      );
    });
  });

  group('getNextReviewTimes', () {
    test(
      'returns human-readable next review labels for early learning cards',
      () {
        final result = engine.getNextReviewTimes(_card());

        expect(result[ReviewRating.again], '< 1m');
        expect(result[ReviewRating.hard], '10m');
        expect(result[ReviewRating.good], '1d');
        expect(result[ReviewRating.easy], '1d');
      },
    );

    test('formats longer review intervals in days', () {
      final result = engine.getNextReviewTimes(
        _card(
          status: CardStatus.reviewing,
          interval: 2,
          repetitions: 2,
          easeFactor: 2,
        ),
      );

      expect(result[ReviewRating.good], '4d');
      expect(result[ReviewRating.easy], '4d');
    });
  });
}

FlashcardEntity _card({
  int id = 1,
  CardStatus status = CardStatus.newCard,
  double easeFactor = 2.5,
  int interval = 0,
  int repetitions = 0,
}) => FlashcardEntity(
  id: id,
  deckId: 1,
  front: 'Front',
  back: 'Back',
  status: status,
  easeFactor: easeFactor,
  interval: interval,
  repetitions: repetitions,
);
