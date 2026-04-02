import 'package:isar/isar.dart';
import 'package:memox/core/network/dto/folder_dto.dart';
import 'package:memox/features/folders/data/models/folder_model.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';

abstract final class FolderMapper {
  static FolderEntity toEntity(FolderModel model) {
    return FolderEntity(
      id: model.id,
      name: model.name,
    );
  }

  static FolderModel toModel(FolderEntity entity) {
    return FolderModel(
      id: entity.id > 0 ? entity.id : Isar.autoIncrement,
      name: entity.name,
    );
  }

  static FolderDto toDto(FolderEntity entity) {
    return FolderDto(
      id: entity.id,
      name: entity.name,
    );
  }

  static FolderEntity fromDto(FolderDto dto) {
    return FolderEntity(
      id: dto.id,
      name: dto.name,
    );
  }
}
