import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/study/domain/support/study_session_type.dart';
import 'package:memox/features/study/domain/usecases/build_study_deck_recommendation.dart';

void main() {
  const deck = DeckEntity(id: 9, name: 'Korean');
  final now = DateTime(2026, 4, 9, 9);

  group('BuildStudyDeckRecommendationUseCase', () {
    test('chooses review when scheduled cards are due', () {
      final useCase = BuildStudyDeckRecommendationUseCase(now: () => now);
      final recommendation = useCase.call(
        deck: deck,
        cards: [
          FlashcardEntity(
            id: 1,
            deckId: 9,
            front: '안녕하세요',
            back: 'Hello',
            status: CardStatus.reviewing,
            nextReviewDate: DateTime(2026, 4, 8),
          ),
          const FlashcardEntity(
            id: 2,
            deckId: 9,
            front: '감사합니다',
            back: 'Thank you',
          ),
        ],
      );

      expect(recommendation?.sessionType, StudySessionType.review);
      expect(
        recommendation?.modePlan,
        orderedEquals([StudyMode.review, StudyMode.recall, StudyMode.fill]),
      );
      expect(recommendation?.dueCards, 1);
      expect(recommendation?.newCards, 1);
    });

    test('chooses first learning when only new cards are available', () {
      final useCase = BuildStudyDeckRecommendationUseCase(now: () => now);
      final recommendation = useCase.call(
        deck: deck,
        cards: const [
          FlashcardEntity(id: 3, deckId: 9, front: '학교', back: 'School'),
        ],
      );

      expect(recommendation?.sessionType, StudySessionType.firstLearning);
      expect(
        recommendation?.modePlan,
        orderedEquals([StudyMode.match, StudyMode.guess, StudyMode.review]),
      );
      expect(recommendation?.dueCards, 0);
      expect(recommendation?.newCards, 1);
    });

    test('returns null when the deck has no eligible study cards', () {
      final useCase = BuildStudyDeckRecommendationUseCase(now: () => now);
      final recommendation = useCase.call(
        deck: deck,
        cards: [
          FlashcardEntity(
            id: 4,
            deckId: 9,
            front: '친구',
            back: 'Friend',
            status: CardStatus.mastered,
            nextReviewDate: DateTime(2026, 4, 30),
          ),
        ],
      );

      expect(recommendation, isNull);
    });
  });
}
