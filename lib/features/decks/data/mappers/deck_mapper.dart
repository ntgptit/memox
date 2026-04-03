import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';

extension DeckRowMapper on DecksTableData {
  DeckEntity toEntity() {
    final decodedTags = tags.isEmpty
        ? const <String>[]
        : List<String>.from(jsonDecode(tags) as List<dynamic>);
    return DeckEntity(
      id: id,
      name: name,
      folderId: folderId,
      description: description,
      colorValue: colorValue,
      tags: decodedTags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sortOrder: sortOrder,
    );
  }
}

extension DeckEntityMapper on DeckEntity {
  DecksTableCompanion toCompanion() {
    final id = this.id > 0 ? Value<int>(this.id) : const Value<int>.absent();
    final createdAt = this.createdAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(this.createdAt!);
    final updatedAt = this.updatedAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(this.updatedAt!);
    return DecksTableCompanion(
      id: id,
      name: Value<String>(name),
      description: Value<String>(description),
      folderId: Value<int>(folderId),
      colorValue: Value<int>(colorValue),
      tags: Value<String>(jsonEncode(tags)),
      createdAt: createdAt,
      updatedAt: updatedAt,
      sortOrder: Value<int>(sortOrder),
    );
  }
}
