import 'package:memox/core/types/result.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class DeleteDeckUseCase {
  const DeleteDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<void>> call(int id) async {
    await _repository.deleteCascade(id);
    return const Result<void>.success(null);
  }
}
