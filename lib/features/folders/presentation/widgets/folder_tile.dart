import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/progress/mastery_ring.dart';

class FolderTile extends StatelessWidget {
  const FolderTile({
    required this.folder,
    required this.subtitle,
    required this.masteryPercentage,
    required this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final FolderEntity folder;
  final String subtitle;
  final double masteryPercentage;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    onLongPress: onLongPress,
    child: Row(
      children: [
        _FolderLeading(colorValue: folder.colorValue),
        const SizedBox(width: SpacingTokens.lg),
        Expanded(
          child: _FolderText(name: folder.name, subtitle: subtitle),
        ),
        const SizedBox(width: SpacingTokens.md),
        MasteryRing(
          percentage: masteryPercentage,
          showZeroPercentText: true,
        ),
        if (onEdit != null || onDelete != null) ...[
          const SizedBox(width: SpacingTokens.xs),
          _FolderActionMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ],
    ),
  );
}

enum _FolderAction { edit, delete }

class _FolderActionMenu extends StatelessWidget {
  const _FolderActionMenu({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_FolderAction>(
    icon: const Icon(Icons.more_vert),
    padding: EdgeInsets.zero,
    position: PopupMenuPosition.under,
    menuPadding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
    onSelected: (_FolderAction action) {
      if (action == _FolderAction.edit) {
        onEdit?.call();
        return;
      }

      onDelete?.call();
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<_FolderAction>>[
      if (onEdit != null)
        PopupMenuItem<_FolderAction>(
          value: _FolderAction.edit,
          height: SizeTokens.listItemCompact,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          child: _FolderActionItem(
            icon: Icons.edit_outlined,
            label: context.l10n.editAction,
          ),
        ),
      if (onDelete != null)
        PopupMenuItem<_FolderAction>(
          value: _FolderAction.delete,
          height: SizeTokens.listItemCompact,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          child: _FolderActionItem(
            icon: Icons.delete_outline,
            label: context.l10n.deleteFolder,
            color: context.customColors.ratingAgain,
          ),
        ),
    ],
  );
}

class _FolderActionItem extends StatelessWidget {
  const _FolderActionItem({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = color ?? context.colors.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: SizeTokens.iconSm, color: foregroundColor),
        const SizedBox(width: SpacingTokens.md),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(color: foregroundColor),
        ),
      ],
    );
  }
}

class _FolderLeading extends StatelessWidget {
  const _FolderLeading({required this.colorValue});

  final int colorValue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color(colorValue).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SpacingTokens.md),
      ),
      child: const SizedBox.square(
        dimension: SizeTokens.avatarLg,
        child: Icon(Icons.folder_outlined),
      ),
    );
  }
}

class _FolderText extends StatelessWidget {
  const _FolderText({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(name, style: Theme.of(context).textTheme.titleMedium),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
