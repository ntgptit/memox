import 'package:memox/core/types/failure.dart';
import 'package:memox/core/types/result.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class UpdateCardUseCase {
  const UpdateCardUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<FlashcardEntity>> call({
    required int id,
    required String front,
    required String back,
    String hint = '',
    String example = '',
    List<String> tags = const <String>[],
  }) async {
    final existing = await _repository.getById(id);

    if (existing == null) {
      return const Result.failure(Failure.notFound('Card not found'));
    }

    final trimmedFront = front.trim();
    final trimmedBack = back.trim();

    if (trimmedFront.isEmpty) {
      return const Result.failure(
        Failure.validation('Front text must not be empty'),
      );
    }

    if (trimmedBack.isEmpty) {
      return const Result.failure(
        Failure.validation('Back text must not be empty'),
      );
    }

    final saved = await _repository.save(
      existing.copyWith(
        front: trimmedFront,
        back: trimmedBack,
        hint: hint.trim(),
        example: example.trim(),
        tags: tags,
      ),
    );
    return Result<FlashcardEntity>.success(saved);
  }
}
