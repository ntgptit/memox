import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/search/domain/value_objects/search_result_item.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    required this.item,
    required this.onTap,
    this.showDivider = false,
    super.key,
  });

  final SearchResultItem item;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => AppListTile(
    title: item.name,
    subtitle: _subtitle,
    variant: AppListTileVariant.search,
    leading: Icon(_icon, color: context.colors.onSurfaceVariant),
    trailing: Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
    onTap: onTap,
    showDivider: showDivider,
  );

  IconData get _icon => switch (item) {
    FolderResult() => Icons.folder_outlined,
    DeckResult() => Icons.style_outlined,
    CardResult() => Icons.credit_card_outlined,
  };

  String? get _subtitle => switch (item) {
    FolderResult(:final parentName) => parentName,
    DeckResult(:final folderName) => folderName,
    CardResult(:final deckName) => deckName,
  };
}
