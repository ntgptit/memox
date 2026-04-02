class DeckEntity {
  const DeckEntity({
    required this.id,
    required this.name,
    this.folderId = 0,
    this.description = '',
    this.colorValue = 0xFF5C6BC0,
    this.tags = const <String>[],
    this.createdAt,
    this.updatedAt,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final int folderId;
  final String description;
  final int colorValue;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int sortOrder;

  DeckEntity copyWith({
    int? id,
    String? name,
    int? folderId,
    String? description,
    int? colorValue,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return DeckEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      folderId: folderId ?? this.folderId,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
