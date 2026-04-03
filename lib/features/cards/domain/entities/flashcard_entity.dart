import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/core/design/card_status.dart';

part 'flashcard_entity.freezed.dart';
part 'flashcard_entity.g.dart';

@freezed
abstract class FlashcardEntity with _$FlashcardEntity {
  const factory FlashcardEntity({
    required int id,
    required String front,
    required String back,
    @Default(0) int deckId,
    @Default('') String hint,
    @Default('') String example,
    @Default(<String>[]) List<String> tags,
    @Default('') String imagePath,
    @Default(CardStatus.newCard) CardStatus status,
    @Default(2.5) double easeFactor,
    @Default(0) int interval,
    @Default(0) int repetitions,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FlashcardEntity;

  factory FlashcardEntity.fromJson(Map<String, dynamic> json) =>
      _$FlashcardEntityFromJson(json);
}
