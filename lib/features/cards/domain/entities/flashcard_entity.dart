class FlashcardEntity {
  const FlashcardEntity({
    required this.id,
    required this.front,
    required this.back,
  });

  final int id;
  final String front;
  final String back;

  FlashcardEntity copyWith({
    int? id,
    String? front,
    String? back,
  }) {
    return FlashcardEntity(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
    );
  }
}
