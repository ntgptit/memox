class DeckEntity {
  const DeckEntity({required this.id, required this.name});

  final int id;
  final String name;

  DeckEntity copyWith({
    int? id,
    String? name,
  }) {
    return DeckEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
