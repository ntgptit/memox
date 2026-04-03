import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
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
    this.isSortMode = false,
    super.key,
  });

  final List<FolderEntity> folders;
  final ValueChanged<FolderEntity> onTap;
  final ValueChanged<FolderEntity> onEdit;
  final ValueChanged<FolderEntity> onDelete;
  final ReorderCallback onReorder;
  final bool isSortMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ReorderableListWidget<FolderEntity>(
      items: folders,
      onReorder: onReorder,
      isReorderEnabled: isSortMode,
      itemBuilder: (context, folder, index) {
        final detail = switch (ref.watch(folderDetailProvider(folder.id))) {
          AsyncData<FolderDetailData>(:final value) => value,
          _ => null,
        };
        final subtitle = detail == null
            ? context.l10n.folderEmptyStatus
            : _subtitle(context, detail);

        return Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: FadeInWidget(
            delay: Duration(
              milliseconds: DurationTokens.staggerDelay.inMilliseconds * index,
            ),
            child: FolderTile(
              folder: folder,
              subtitle: subtitle,
              masteryPercentage: detail?.masteryPercentage ?? 0,
              onTap: isSortMode ? null : () => onTap(folder),
              onEdit: isSortMode ? null : () => onEdit(folder),
              onDelete: isSortMode ? null : () => onDelete(folder),
            ),
          ),
        );
      },
    );

  String _subtitle(BuildContext context, FolderDetailData detail) => switch (detail.contentType) {
      ContentType.subfolders => context.l10n.folderSubfolderCount(
        detail.subfolderCount,
      ),
      ContentType.decks => context.l10n.folderDeckSubtitle(
        detail.deckCount,
        detail.totalCards,
      ),
      ContentType.empty => context.l10n.folderEmptyStatus,
    };
}
