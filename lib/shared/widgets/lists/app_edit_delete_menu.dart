import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

enum _AppEditDeleteAction { edit, delete }

class AppEditDeleteMenu extends StatelessWidget {
  const AppEditDeleteMenu({
    required this.deleteLabel,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final String deleteLabel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_AppEditDeleteAction>(
    icon: const Icon(Icons.more_vert),
    padding: EdgeInsets.zero,
    position: PopupMenuPosition.under,
    menuPadding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
    onSelected: (_AppEditDeleteAction action) {
      switch (action) {
        case _AppEditDeleteAction.edit:
          onEdit?.call();
          return;
        case _AppEditDeleteAction.delete:
          onDelete?.call();
      }
    },
    itemBuilder: (BuildContext context) =>
        <PopupMenuEntry<_AppEditDeleteAction>>[
          if (onEdit != null)
            _AppActionMenuItem(
              action: _AppEditDeleteAction.edit,
              icon: Icons.edit_outlined,
              label: context.l10n.editAction,
            ),
          if (onDelete != null)
            _AppActionMenuItem(
              action: _AppEditDeleteAction.delete,
              icon: Icons.delete_outline,
              label: deleteLabel,
              color: context.colors.error,
            ),
        ],
  );
}

class _AppActionMenuItem extends PopupMenuItem<_AppEditDeleteAction> {
  _AppActionMenuItem({
    required _AppEditDeleteAction action,
    required IconData icon,
    required String label,
    Color? color,
  }) : super(
         value: action,
         height: SizeTokens.listItemCompact,
         padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
         child: Builder(
           builder: (BuildContext context) {
             final foregroundColor = color ?? context.colors.onSurface;
             return Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(icon, size: SizeTokens.iconSm, color: foregroundColor),
                 const Gap.md(),
                 Text(
                   label,
                   style: context.textTheme.bodyMedium?.copyWith(
                     color: foregroundColor,
                   ),
                 ),
               ],
             );
           },
         ),
       );
}
