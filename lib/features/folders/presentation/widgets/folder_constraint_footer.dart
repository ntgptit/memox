import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
import 'package:memox/shared/widgets/cards/info_bar.dart';

class FolderConstraintFooter extends StatelessWidget {
  const FolderConstraintFooter({
    required this.contentType,
    required this.depth,
    super.key,
  });

  final ContentType contentType;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (contentType == ContentType.subfolders)
        InfoBar(
          icon: Icons.rule_folder_outlined,
          text: context.l10n.folderConstraintDecks,
        ),
      if (contentType == ContentType.decks)
        InfoBar(
          icon: Icons.rule_outlined,
          text: context.l10n.folderConstraintSubfolders,
        ),
      if (depth > 3)
        InfoBar(
          icon: Icons.warning_amber_outlined,
          text: context.l10n.folderDepthWarning(depth),
        ),
    ];

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: SpacingTokens.lg),
        ...children,
      ],
    );
  }
}
