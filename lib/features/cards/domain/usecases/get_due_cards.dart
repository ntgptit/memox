import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class GetDueCardsUseCase {
  const GetDueCardsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<List<FlashcardEntity>> call({int? deckId, int limit = 20}) => _repository.getDueCards(deckId: deckId, limit: limit);
}
