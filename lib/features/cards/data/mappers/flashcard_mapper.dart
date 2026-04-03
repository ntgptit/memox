import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

extension FlashcardRowMapper on CardsTableData {
  FlashcardEntity toEntity() {
    final decodedTags = tags.isEmpty
        ? const <String>[]
        : List<String>.from(jsonDecode(tags) as List<dynamic>);
    return FlashcardEntity(
      id: id,
      deckId: deckId,
      front: front,
      back: back,
      hint: hint,
      example: example,
      tags: decodedTags,
      imagePath: imagePath,
      status: status,
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      nextReviewDate: nextReviewDate,
      lastReviewedAt: lastReviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension FlashcardEntityMapper on FlashcardEntity {
  CardsTableCompanion toCompanion() {
    final id = this.id > 0 ? Value<int>(this.id) : const Value<int>.absent();
    final nextReviewDate = this.nextReviewDate == null
        ? const Value<DateTime?>.absent()
        : Value<DateTime?>(this.nextReviewDate);
    final lastReviewedAt = this.lastReviewedAt == null
        ? const Value<DateTime?>.absent()
        : Value<DateTime?>(this.lastReviewedAt);
    final createdAt = this.createdAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(this.createdAt!);
    final updatedAt = this.updatedAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(this.updatedAt!);
    return CardsTableCompanion(
      id: id,
      deckId: Value<int>(deckId),
      front: Value<String>(front),
      back: Value<String>(back),
      hint: Value<String>(hint),
      example: Value<String>(example),
      tags: Value<String>(jsonEncode(tags)),
      imagePath: Value<String>(imagePath),
      status: Value(status),
      easeFactor: Value<double>(easeFactor),
      interval: Value<int>(interval),
      repetitions: Value<int>(repetitions),
      nextReviewDate: nextReviewDate,
      lastReviewedAt: lastReviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
