import 'package:json_annotation/json_annotation.dart';

part 'folder_dto.g.dart';

@JsonSerializable()
class FolderDto {
  const FolderDto({
    required this.id,
    required this.name,
  });

  factory FolderDto.fromJson(Map<String, dynamic> json) =>
      _$FolderDtoFromJson(json);

  final int id;
  final String name;

  Map<String, dynamic> toJson() => _$FolderDtoToJson(this);
}
