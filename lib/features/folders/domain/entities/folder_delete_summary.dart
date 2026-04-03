import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_delete_summary.freezed.dart';
part 'folder_delete_summary.g.dart';

@freezed
abstract class FolderDeleteSummary with _$FolderDeleteSummary {
  const factory FolderDeleteSummary({
    @Default(0) int subfolderCount,
    @Default(0) int deckCount,
    @Default(0) int cardCount,
    @Default(0) int reviewCount,
  }) = _FolderDeleteSummary;

  factory FolderDeleteSummary.fromJson(Map<String, dynamic> json) =>
      _$FolderDeleteSummaryFromJson(json);
}

extension FolderDeleteSummaryX on FolderDeleteSummary {
  int get totalItemCount =>
      subfolderCount + deckCount + cardCount + reviewCount;
}
