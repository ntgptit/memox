import 'package:memox/core/types/result.dart';
import 'package:memox/features/cards/domain/entities/card_batch_parse_result.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';

final class CreateCardsBatchUseCase {
  const CreateCardsBatchUseCase(this._repository);

  final FlashcardRepository _repository;

  CardBatchParseResult preview({
    required String rawText,
    required String separator,
    required int deckId,
  }) {
    final parsed = <FlashcardEntity>[];
    final errors = <String>[];
    final lines = rawText.split('\n');

    for (var index = 0; index < lines.length; index++) {
      final sourceLine = lines[index].trim();

      if (sourceLine.isEmpty) {
        continue;
      }

      final separatorIndex = sourceLine.indexOf(separator);

      if (separatorIndex < 0) {
        errors.add('Line ${index + 1}: missing separator');
        continue;
      }

      final front = sourceLine.substring(0, separatorIndex).trim();
      final back = sourceLine
          .substring(separatorIndex + separator.length)
          .trim();

      if (front.isEmpty || back.isEmpty) {
        errors.add('Line ${index + 1}: both front and back are required');
        continue;
      }

      parsed.add(
        FlashcardEntity(id: 0, deckId: deckId, front: front, back: back),
      );
    }

    return (parsed: parsed, errors: errors);
  }

  Future<Result<CardBatchParseResult>> call({
    required String rawText,
    required String separator,
    required int deckId,
  }) async {
    final previewResult = preview(
      rawText: rawText,
      separator: separator,
      deckId: deckId,
    );

    if (previewResult.parsed.isNotEmpty) {
      await _repository.saveAll(previewResult.parsed);
    }

    return Result<CardBatchParseResult>.success(previewResult);
  }
}
