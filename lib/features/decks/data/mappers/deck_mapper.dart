import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';

abstract final class DeckMapper {
  static DeckEntity toEntity(DecksTableData row) {
    final tags = row.tags.isEmpty
        ? const <String>[]
        : List<String>.from(jsonDecode(row.tags) as List<dynamic>);
    return DeckEntity(
      id: row.id,
      name: row.name,
      folderId: row.folderId,
      description: row.description,
      colorValue: row.colorValue,
      tags: tags,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      sortOrder: row.sortOrder,
    );
  }

  static DecksTableCompanion toCompanion(DeckEntity entity) {
    final id = entity.id > 0
        ? Value<int>(entity.id)
        : const Value<int>.absent();
    final createdAt = entity.createdAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(entity.createdAt!);
    final updatedAt = entity.updatedAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(entity.updatedAt!);
    return DecksTableCompanion(
      id: id,
      name: Value<String>(entity.name),
      description: Value<String>(entity.description),
      folderId: Value<int>(entity.folderId),
      colorValue: Value<int>(entity.colorValue),
      tags: Value<String>(jsonEncode(entity.tags)),
      createdAt: createdAt,
      updatedAt: updatedAt,
      sortOrder: Value<int>(entity.sortOrder),
    );
  }
}
