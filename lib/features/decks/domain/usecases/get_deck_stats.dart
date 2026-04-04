import 'package:memox/core/design/card_status.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';

final class GetDeckStatsUseCase {
  const GetDeckStatsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<DeckStats> call(int deckId) async {
    final cards = await _repository.getByDeck(deckId);
    final now = DateTime.now();
    var due = 0;
    final known = cards.where((FlashcardEntity card) => card.status == CardStatus.mastered).length;
    final learning = cards.where((FlashcardEntity card) => card.status == CardStatus.learning ||
          card.status == CardStatus.reviewing).length;
    final newCards = cards.where((FlashcardEntity card) => card.status == CardStatus.newCard).length;

    for (final card in cards) {
      if (card.status == CardStatus.newCard) {
        due++;
        continue;
      }

      final nextReviewDate = card.nextReviewDate;

      if (nextReviewDate == null) {
        continue;
      }

      if (!nextReviewDate.isAfter(now)) {
        due++;
      }
    }

    final mastery = cards.isEmpty ? 0.0 : known / cards.length;
    return (
      total: cards.length,
      due: due,
      known: known,
      learning: learning,
      newCards: newCards,
      mastery: mastery,
    );
  }
}
