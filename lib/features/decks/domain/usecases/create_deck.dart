import 'package:memox/core/guards/preconditions.dart';
import 'package:memox/core/database/db_constants.dart';
import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';
import 'package:memox/features/folders/domain/usecases/can_create_deck.dart';

final class CreateDeckUseCase {
  const CreateDeckUseCase({
    required DeckRepository repository,
    required CanCreateDeckUseCase canCreateDeckUseCase,
  }) : _repository = repository,
       _canCreateDeckUseCase = canCreateDeckUseCase;

  final DeckRepository _repository;
  final CanCreateDeckUseCase _canCreateDeckUseCase;

  Future<Result<DeckEntity>> call({
    required String name,
    required int folderId,
    String description = '',
    int colorValue = DbConstants.defaultColorValue,
    List<String> tags = const <String>[],
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return const Result.failure(
        Failure.validation('Deck name must not be empty'),
      );
    }

    Preconditions.requireNotEmpty(trimmedName, name: 'name');
    final canCreateDeck = await _canCreateDeckUseCase.call(folderId);

    if (!canCreateDeck) {
      return const Result.failure(
        Failure.validation('This folder can only contain subfolders'),
      );
    }

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
        description: description.trim(),
        colorValue: colorValue,
        tags: tags,
        sortOrder: nextSortOrder,
      ),
    );
    return Result<DeckEntity>.success(saved);
  }
}
