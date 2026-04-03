import 'package:memox/core/guards/preconditions.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';

final class UpdateDeckUseCase {
  const UpdateDeckUseCase({
    required DeckRepository repository,
    required AppLogger logger,
  }) : _repository = repository,
       _logger = logger;

  final DeckRepository _repository;
  final AppLogger _logger;

  Future<Result<DeckEntity>> call({
    required int id,
    required String name,
    required String description,
    required int colorValue,
    required List<String> tags,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return const Result.failure(
        Failure.validation('Deck name must not be empty'),
      );
    }

    Preconditions.requireNotEmpty(trimmedName, name: 'name');
    final existingDeck = await _repository.getById(id);

    if (existingDeck == null) {
      return const Result.failure(Failure.notFound('Deck not found'));
    }

    final siblingDecks = await _repository.getByFolder(existingDeck.folderId);
    final duplicateExists = siblingDecks.any(
      (DeckEntity deck) =>
          deck.id != id &&
          deck.name.trim().toLowerCase() == trimmedName.toLowerCase(),
    );

    if (duplicateExists) {
      return const Result.failure(
        Failure.conflict('A deck with this name already exists here'),
      );
    }

    final saved = await _repository.save(
      existingDeck.copyWith(
        name: trimmedName,
        description: description.trim(),
        colorValue: colorValue,
        tags: tags,
      ),
    );
    _logger.info('Deck updated: ${saved.id}');
    return Result<DeckEntity>.success(saved);
  }
}
