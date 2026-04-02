import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

abstract final class FlashcardMapper {
  static FlashcardEntity toEntity(CardsTableData row) {
    return FlashcardEntity(
      id: row.id,
      deckId: row.deckId,
      front: row.front,
      back: row.back,
      hint: row.hint,
      example: row.example,
      imagePath: row.imagePath,
      status: row.status,
      easeFactor: row.easeFactor,
      interval: row.interval,
      repetitions: row.repetitions,
      nextReviewDate: row.nextReviewDate,
      lastReviewedAt: row.lastReviewedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static CardsTableCompanion toCompanion(FlashcardEntity entity) {
    final id = entity.id > 0
        ? Value<int>(entity.id)
        : const Value<int>.absent();
    final nextReviewDate = entity.nextReviewDate == null
        ? const Value<DateTime?>.absent()
        : Value<DateTime?>(entity.nextReviewDate);
    final lastReviewedAt = entity.lastReviewedAt == null
        ? const Value<DateTime?>.absent()
        : Value<DateTime?>(entity.lastReviewedAt);
    final createdAt = entity.createdAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(entity.createdAt!);
    final updatedAt = entity.updatedAt == null
        ? const Value<DateTime>.absent()
        : Value<DateTime>(entity.updatedAt!);
    return CardsTableCompanion(
      id: id,
      deckId: Value<int>(entity.deckId),
      front: Value<String>(entity.front),
      back: Value<String>(entity.back),
      hint: Value<String>(entity.hint),
      example: Value<String>(entity.example),
      imagePath: Value<String>(entity.imagePath),
      status: Value(entity.status),
      easeFactor: Value<double>(entity.easeFactor),
      interval: Value<int>(entity.interval),
      repetitions: Value<int>(entity.repetitions),
      nextReviewDate: nextReviewDate,
      lastReviewedAt: lastReviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
