import 'package:json_annotation/json_annotation.dart';
import 'package:memox/core/network/dto/card_dto.dart';
import 'package:memox/core/network/dto/deck_dto.dart';
import 'package:memox/core/network/dto/folder_dto.dart';

part 'sync_payload_dto.g.dart';

@JsonSerializable()
class SyncPayloadDto {
  const SyncPayloadDto({
    this.folders = const <FolderDto>[],
    this.decks = const <DeckDto>[],
    this.cards = const <CardDto>[],
  });

  factory SyncPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$SyncPayloadDtoFromJson(json);

  final List<FolderDto> folders;
  final List<DeckDto> decks;
  final List<CardDto> cards;

  Map<String, dynamic> toJson() => _$SyncPayloadDtoToJson(this);
}
