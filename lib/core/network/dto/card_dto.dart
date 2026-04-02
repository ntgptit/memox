import 'package:json_annotation/json_annotation.dart';

part 'card_dto.g.dart';

@JsonSerializable()
class CardDto {
  const CardDto({
    required this.id,
    required this.front,
    required this.back,
  });

  factory CardDto.fromJson(Map<String, dynamic> json) =>
      _$CardDtoFromJson(json);

  final int id;
  final String front;
  final String back;

  Map<String, dynamic> toJson() => _$CardDtoToJson(this);
}
