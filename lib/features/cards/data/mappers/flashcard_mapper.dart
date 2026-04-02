import 'package:isar/isar.dart';
import 'package:memox/core/network/dto/card_dto.dart';
import 'package:memox/features/cards/data/models/flashcard_model.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

abstract final class FlashcardMapper {
  static FlashcardEntity toEntity(FlashcardModel model) {
    return FlashcardEntity(
      id: model.id,
      front: model.front,
      back: model.back,
    );
  }

  static FlashcardModel toModel(FlashcardEntity entity) {
    return FlashcardModel(
      id: entity.id > 0 ? entity.id : Isar.autoIncrement,
      front: entity.front,
      back: entity.back,
    );
  }

  static CardDto toDto(FlashcardEntity entity) {
    return CardDto(
      id: entity.id,
      front: entity.front,
      back: entity.back,
    );
  }
}
