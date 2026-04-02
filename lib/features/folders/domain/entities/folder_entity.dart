class FolderEntity {
  const FolderEntity({required this.id, required this.name});

  final int id;
  final String name;

  FolderEntity copyWith({
    int? id,
    String? name,
  }) {
    return FolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
