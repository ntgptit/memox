import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class ReorderDecksUseCase {
  const ReorderDecksUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<void>> call({
    required int folderId,
    required List<int> deckIds,
  }) async {
    if (deckIds.isEmpty) {
      return const Result<void>.success(null);
    }

    try {
      await _repository.reorder(folderId: folderId, deckIds: deckIds);
      return const Result<void>.success(null);
    } catch (_) {
      return const Result.failure(
        Failure.unknown('Unable to reorder decks'),
      );
    }
  }
}
