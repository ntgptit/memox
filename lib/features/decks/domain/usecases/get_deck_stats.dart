import 'package:memox/core/design/card_status.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';

final class GetDeckStatsUseCase {
  const GetDeckStatsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<DeckStats> call(int deckId) async {
    final cards = await _repository.getByDeck(deckId);
    final dueCards = await _repository.getDueCards(
      deckId: deckId,
      limit: cards.length,
    );
    final known = cards.where((FlashcardEntity card) {
      return card.status == CardStatus.mastered;
    }).length;
    final learning = cards.where((FlashcardEntity card) {
      return card.status == CardStatus.learning ||
          card.status == CardStatus.reviewing;
    }).length;
    final newCards = cards.where((FlashcardEntity card) {
      return card.status == CardStatus.newCard;
    }).length;
    final mastery = cards.isEmpty ? 0.0 : known / cards.length;
    return (
      total: cards.length,
      due: dueCards.length,
      known: known,
      learning: learning,
      newCards: newCards,
      mastery: mastery,
    );
  }
}
