import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class GetCardsByDeckUseCase {
  const GetCardsByDeckUseCase(this._repository);

  final FlashcardRepository _repository;

  Stream<List<FlashcardEntity>> call(int deckId) =>
      _repository.watchByDeck(deckId);
}
