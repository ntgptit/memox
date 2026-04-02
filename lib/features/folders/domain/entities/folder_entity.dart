class FolderEntity {
  const FolderEntity({
    required this.id,
    required this.name,
    this.parentId,
    this.colorValue = 0xFF5C6BC0,
    this.createdAt,
    this.updatedAt,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final int? parentId;
  final int colorValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int sortOrder;

  FolderEntity copyWith({
    int? id,
    String? name,
    int? parentId,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return FolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
