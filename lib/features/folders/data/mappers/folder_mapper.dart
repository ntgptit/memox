import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';

extension FolderRowMapper on FoldersTableData {
  FolderEntity toEntity() => FolderEntity(
    id: id,
    name: name,
    parentId: parentId,
    colorValue: colorValue,
    createdAt: createdAt,
    updatedAt: updatedAt,
    sortOrder: sortOrder,
  );
}

extension FolderEntityMapper on FolderEntity {
  FoldersTableCompanion toCompanion() {
    final id = this.id > 0 ? Value<int>(this.id) : const Value<int>.absent();
    final createdAt = this.createdAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(this.createdAt!);
    final updatedAt = this.updatedAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(this.updatedAt!);
    return FoldersTableCompanion(
      id: id,
      name: Value<String>(name),
      parentId: Value<int?>(parentId),
      colorValue: Value<int>(colorValue),
      createdAt: createdAt,
      updatedAt: updatedAt,
      sortOrder: Value<int>(sortOrder),
    );
  }
}
