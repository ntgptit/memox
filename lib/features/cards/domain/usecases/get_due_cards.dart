import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class GetDueCardsUseCase {
  const GetDueCardsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<List<FlashcardEntity>> call() => _repository.getDueCards();
}
