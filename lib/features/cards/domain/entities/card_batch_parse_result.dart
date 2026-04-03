import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

typedef CardBatchParseResult = ({
  List<FlashcardEntity> parsed,
  List<String> errors,
});
