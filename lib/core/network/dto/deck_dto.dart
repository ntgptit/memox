import 'package:json_annotation/json_annotation.dart';

part 'deck_dto.g.dart';

@JsonSerializable()
class DeckDto {
  const DeckDto({
    required this.id,
    required this.name,
  });

  factory DeckDto.fromJson(Map<String, dynamic> json) =>
      _$DeckDtoFromJson(json);

  final int id;
  final String name;

  Map<String, dynamic> toJson() => _$DeckDtoToJson(this);
}
