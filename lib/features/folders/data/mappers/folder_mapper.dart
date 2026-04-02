import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';

abstract final class FolderMapper {
  static FolderEntity toEntity(FoldersTableData row) {
    return FolderEntity(
      id: row.id,
      name: row.name,
      parentId: row.parentId,
      colorValue: row.colorValue,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      sortOrder: row.sortOrder,
    );
  }

  static FoldersTableCompanion toCompanion(FolderEntity entity) {
    final id = entity.id > 0
        ? Value<int>(entity.id)
        : const Value<int>.absent();
    final createdAt = entity.createdAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(entity.createdAt!);
    final updatedAt = entity.updatedAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(entity.updatedAt!);
    return FoldersTableCompanion(
      id: id,
      name: Value<String>(entity.name),
      parentId: Value<int?>(entity.parentId),
      colorValue: Value<int>(entity.colorValue),
      createdAt: createdAt,
      updatedAt: updatedAt,
      sortOrder: Value<int>(entity.sortOrder),
    );
  }
}
