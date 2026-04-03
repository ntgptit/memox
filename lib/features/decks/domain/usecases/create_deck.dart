import 'package:memox/core/guards/preconditions.dart';
import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class CreateDeckUseCase {
  const CreateDeckUseCase(this._repository);

  final DeckRepository _repository;

  Future<Result<DeckEntity>> call({
    required String name,
    required int folderId,
    required int colorValue,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return const Result.failure(
        Failure.validation('Deck name must not be empty'),
      );
    }

    Preconditions.requireNotEmpty(trimmedName, name: 'name');
    final decks = await _repository.getByFolder(folderId);
    final duplicateExists = decks.any((DeckEntity deck) {
      return deck.name.trim().toLowerCase() == trimmedName.toLowerCase();
    });

    if (duplicateExists) {
      return const Result.failure(
        Failure.conflict('A deck with this name already exists here'),
      );
    }

    final nextSortOrder = await _repository.getNextSortOrder(folderId);
    final saved = await _repository.save(
      DeckEntity(
        id: 0,
        name: trimmedName,
        folderId: folderId,
        colorValue: colorValue,
        sortOrder: nextSortOrder,
      ),
    );
    return Result<DeckEntity>.success(saved);
  }
}
