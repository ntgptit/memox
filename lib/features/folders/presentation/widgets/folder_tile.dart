import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';
import 'package:memox/shared/widgets/lists/app_card_list_tile.dart';
import 'package:memox/shared/widgets/lists/app_edit_delete_menu.dart';
import 'package:memox/shared/widgets/lists/app_tile_glyph.dart';
import 'package:memox/shared/widgets/progress/mastery_ring.dart';

class FolderTile extends StatelessWidget {
  const FolderTile({
    required this.folder,
    required this.subtitle,
    required this.masteryPercentage,
    required this.onTap,
    this.reorderHandle,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final FolderEntity folder;
  final String subtitle;
  final double masteryPercentage;
  final VoidCallback? onTap;
  final Widget? reorderHandle;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => AppCardListTile(
    onTap: onTap,
    onLongPress: onLongPress,
    leading: AppTileGlyph(
      icon: Icons.folder_outlined,
      color: Color(folder.colorValue),
    ),
    title: Text(folder.name, style: context.textTheme.titleMedium),
    subtitle: Text(
      subtitle,
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    ),
    trailing: _FolderTrailing(
      masteryPercentage: masteryPercentage,
      reorderHandle: reorderHandle,
      onEdit: onEdit,
      onDelete: onDelete,
    ),
  );
}

class _FolderTrailing extends StatelessWidget {
  const _FolderTrailing({
    required this.masteryPercentage,
    this.reorderHandle,
    this.onEdit,
    this.onDelete,
  });

  final double masteryPercentage;
  final Widget? reorderHandle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      MasteryRing(percentage: masteryPercentage, showZeroPercentText: true),
      if (reorderHandle != null) ...[const Gap.sm(), reorderHandle!],
      if (onEdit != null || onDelete != null) ...[
        const Gap.sm(),
        AppEditDeleteMenu(
          deleteLabel: context.l10n.deleteFolder,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ],
    ],
  );
}
