import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_entity.freezed.dart';
part 'folder_entity.g.dart';

@freezed
abstract class FolderEntity with _$FolderEntity {
  const factory FolderEntity({
    required int id,
    required String name,
    int? parentId,
    @Default(0xFF5C6BC0) int colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int sortOrder,
  }) = _FolderEntity;

  factory FolderEntity.fromJson(Map<String, dynamic> json) =>
      _$FolderEntityFromJson(json);
}
