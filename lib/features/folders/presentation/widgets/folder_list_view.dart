import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/providers/folders_provider.dart';
import 'package:memox/features/folders/presentation/widgets/folder_tile.dart';
import 'package:memox/shared/widgets/animations/fade_in_widget.dart';
import 'package:memox/shared/widgets/lists/reorderable_list.dart';

class FolderListView extends ConsumerWidget {
  const FolderListView({
    required this.folders,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
    this.header,
    this.onRefresh,
    this.isSortMode = false,
    super.key,
  });

  final List<FolderEntity> folders;
  final ValueChanged<FolderEntity> onTap;
  final ValueChanged<FolderEntity> onEdit;
  final ValueChanged<FolderEntity> onDelete;
  final ReorderCallback onReorder;
  final Widget? header;
  final RefreshCallback? onRefresh;
  final bool isSortMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ReorderableListWidget<FolderEntity>(
        items: folders,
        onReorder: onReorder,
        header: header,
        onRefresh: onRefresh,
        isReorderEnabled: isSortMode,
        itemBuilder: (context, folder, index, reorderHandle) {
          final summary = switch (ref.watch(
            homeFolderTileDataProvider(folder.id),
          )) {
            AsyncData<HomeFolderTileData>(:final value) => value,
            _ => null,
          };
          final subtitle = summary == null
              ? context.l10n.folderEmptyStatus
              : _subtitle(context, summary);

          return Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
            child: FadeInWidget(
              delay: Duration(
                milliseconds:
                    DurationTokens.staggerDelay.inMilliseconds * index,
              ),
              child: FolderTile(
                folder: folder,
                subtitle: subtitle,
                masteryPercentage: summary?.masteryPercentage ?? 0,
                reorderHandle: isSortMode ? reorderHandle : null,
                onTap: isSortMode ? null : () => onTap(folder),
                onEdit: isSortMode ? null : () => onEdit(folder),
                onDelete: isSortMode ? null : () => onDelete(folder),
              ),
            ),
          );
        },
      );

  String _subtitle(BuildContext context, HomeFolderTileData summary) =>
      switch ((summary.directSubfolderCount > 0, summary.directDeckCount > 0)) {
        (true, _) => context.l10n.folderSubfolderCount(
          summary.directSubfolderCount,
        ),
        (false, true) => context.l10n.folderDeckSubtitle(
          summary.directDeckCount,
          summary.totalCards,
        ),
        _ => context.l10n.folderEmptyStatus,
      };
}
