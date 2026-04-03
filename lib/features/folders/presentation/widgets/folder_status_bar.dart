import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/folders/presentation/providers/folder_detail_provider.dart';
import 'package:memox/shared/widgets/cards/info_bar.dart';

class FolderStatusBar extends StatelessWidget {
  const FolderStatusBar({required this.detail, super.key});

  final FolderDetailData detail;

  @override
  Widget build(BuildContext context) {
    final text = switch (detail.contentType) {
      ContentType.subfolders => context.l10n.folderContainsSubfolders(
        detail.subfolderCount,
      ),
      ContentType.decks => context.l10n.folderContainsDecks(
        detail.deckCount,
        detail.totalCards,
      ),
      ContentType.empty => context.l10n.folderStatusEmpty,
    };

    return InfoBar(icon: Icons.inventory_2_outlined, text: text);
  }
}
