import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class GetFlashcardsUseCase {
  const GetFlashcardsUseCase(this._repository);

  final FlashcardRepository _repository;

  Stream<List<FlashcardEntity>> call() => _repository.watchAll();
}
