import 'package:memox/core/types/result.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class DeleteCardUseCase {
  const DeleteCardUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<void>> call(int id) async {
    await _repository.delete(id);
    return const Result<void>.success(null);
  }
}
