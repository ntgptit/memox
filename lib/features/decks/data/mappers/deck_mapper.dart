import 'package:isar/isar.dart';
import 'package:memox/core/network/dto/deck_dto.dart';
import 'package:memox/features/decks/data/models/deck_model.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';

abstract final class DeckMapper {
  static DeckEntity toEntity(DeckModel model) {
    return DeckEntity(
      id: model.id,
      name: model.name,
    );
  }

  static DeckModel toModel(DeckEntity entity) {
    return DeckModel(
      id: entity.id > 0 ? entity.id : Isar.autoIncrement,
      name: entity.name,
    );
  }

  static DeckDto toDto(DeckEntity entity) {
    return DeckDto(
      id: entity.id,
      name: entity.name,
    );
  }
}
