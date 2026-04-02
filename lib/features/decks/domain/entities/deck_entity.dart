import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_entity.freezed.dart';
part 'deck_entity.g.dart';

@freezed
abstract class DeckEntity with _$DeckEntity {
  const factory DeckEntity({
    required int id,
    required String name,
    @Default(0) int folderId,
    @Default('') String description,
    @Default(0xFF5C6BC0) int colorValue,
    @Default(<String>[]) List<String> tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int sortOrder,
  }) = _DeckEntity;

  factory DeckEntity.fromJson(Map<String, dynamic> json) =>
      _$DeckEntityFromJson(json);
}
