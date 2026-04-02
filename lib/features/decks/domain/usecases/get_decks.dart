import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class GetDecksUseCase {
  const GetDecksUseCase(this._repository);

  final DeckRepository _repository;

  Stream<List<DeckEntity>> call() => _repository.watchAll();
}
