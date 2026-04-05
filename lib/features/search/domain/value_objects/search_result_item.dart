sealed class SearchResultItem {
  const SearchResultItem({required this.id, required this.name});

  final int id;
  final String name;
}

final class FolderResult extends SearchResultItem {
  const FolderResult({
    required super.id,
    required super.name,
    this.parentName,
  });

  final String? parentName;
}

final class DeckResult extends SearchResultItem {
  const DeckResult({
    required super.id,
    required super.name,
    this.folderName,
  });

  final String? folderName;
}

final class CardResult extends SearchResultItem {
  const CardResult({
    required super.id,
    required super.name,
    required this.deckId,
    required this.back,
    this.deckName,
  });

  final int deckId;
  final String back;
  final String? deckName;
}
