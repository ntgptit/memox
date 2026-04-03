import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_recursive_stats.freezed.dart';
part 'folder_recursive_stats.g.dart';

@freezed
abstract class FolderRecursiveStats with _$FolderRecursiveStats {
  const factory FolderRecursiveStats({
    @Default(0) int subfolderCount,
    @Default(0) int deckCount,
    @Default(0) int totalCards,
    @Default(0) int masteredCards,
  }) = _FolderRecursiveStats;

  factory FolderRecursiveStats.fromJson(Map<String, dynamic> json) =>
      _$FolderRecursiveStatsFromJson(json);
}

extension FolderRecursiveStatsX on FolderRecursiveStats {
  bool get hasDecks => deckCount > 0;

  bool get hasSubfolders => subfolderCount > 0;

  double get masteryPercentage {
    if (totalCards == 0) {
      return 0;
    }

    return masteredCards / totalCards;
  }
}
