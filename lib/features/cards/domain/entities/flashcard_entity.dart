import 'package:memox/core/design/card_status.dart';

class FlashcardEntity {
  const FlashcardEntity({
    required this.id,
    required this.front,
    required this.back,
    this.deckId = 0,
    this.hint = '',
    this.example = '',
    this.imagePath = '',
    this.status = CardStatus.newCard,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReviewDate,
    this.lastReviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int deckId;
  final String front;
  final String back;
  final String hint;
  final String example;
  final String imagePath;
  final CardStatus status;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime? nextReviewDate;
  final DateTime? lastReviewedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FlashcardEntity copyWith({
    int? id,
    int? deckId,
    String? front,
    String? back,
    String? hint,
    String? example,
    String? imagePath,
    CardStatus? status,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FlashcardEntity(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      example: example ?? this.example,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
