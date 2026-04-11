import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/study/domain/support/study_session_type.dart';

typedef StudyDeckRecommendation = ({
  DeckEntity deck,
  StudySessionType sessionType,
  List<StudyMode> modePlan,
  int totalCards,
  int dueCards,
  int newCards,
  int activeCards,
});

extension StudyDeckRecommendationX on StudyDeckRecommendation {
  StudyMode get primaryMode => modePlan.first;
}

final class BuildStudyDeckRecommendationUseCase {
  BuildStudyDeckRecommendationUseCase({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  StudyDeckRecommendation? call({
    required DeckEntity deck,
    required List<FlashcardEntity> cards,
  }) {
    if (cards.isEmpty) {
      return null;
    }

    final now = _now();
    final dueCards = cards.where((card) => _isReviewDue(card, now)).length;
    final newCards = cards
        .where((card) => card.status == CardStatus.newCard)
        .length;
    final activeCards = cards
        .where((card) => card.status != CardStatus.mastered)
        .length;

    if (activeCards == 0) {
      return null;
    }

    final sessionType = _sessionTypeFor(
      dueCards: dueCards,
      newCards: newCards,
      activeCards: activeCards,
    );

    return (
      deck: deck,
      sessionType: sessionType,
      modePlan: _modePlanFor(sessionType),
      totalCards: cards.length,
      dueCards: dueCards,
      newCards: newCards,
      activeCards: activeCards,
    );
  }

  List<StudyMode> _modePlanFor(StudySessionType sessionType) =>
      switch (sessionType) {
        StudySessionType.firstLearning => const <StudyMode>[
          StudyMode.match,
          StudyMode.guess,
          StudyMode.review,
        ],
        StudySessionType.review => const <StudyMode>[
          StudyMode.review,
          StudyMode.recall,
          StudyMode.fill,
        ],
        StudySessionType.reinforcement => const <StudyMode>[
          StudyMode.recall,
          StudyMode.fill,
          StudyMode.guess,
        ],
        StudySessionType.quickDrill => const <StudyMode>[
          StudyMode.guess,
          StudyMode.match,
        ],
      };

  StudySessionType _sessionTypeFor({
    required int dueCards,
    required int newCards,
    required int activeCards,
  }) {
    if (dueCards > 0) {
      return StudySessionType.review;
    }

    if (newCards > 0) {
      return StudySessionType.firstLearning;
    }

    if (activeCards > 0) {
      return StudySessionType.reinforcement;
    }

    return StudySessionType.quickDrill;
  }
}

bool _isReviewDue(FlashcardEntity card, DateTime now) {
  if (card.status == CardStatus.newCard) {
    return false;
  }

  final nextReviewDate = card.nextReviewDate;

  if (nextReviewDate == null) {
    return false;
  }

  return !nextReviewDate.isAfter(now);
}
