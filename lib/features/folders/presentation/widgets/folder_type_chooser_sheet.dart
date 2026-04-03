import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/dialogs/choice_bottom_sheet.dart';

enum FolderCreationKind { subfolder, deck }

class FolderTypeChooserSheet extends StatelessWidget {
  const FolderTypeChooserSheet({super.key});

  @override
  Widget build(BuildContext context) => ChoiceBottomSheet<FolderCreationKind>(
      title: context.l10n.folderTypeChooserTitle,
      options: [
        ChoiceOption<FolderCreationKind>(
          value: FolderCreationKind.subfolder,
          title: context.l10n.createSubfolder,
          subtitle: context.l10n.folderTypeSubfolderDescription,
          icon: Icons.folder_copy_outlined,
        ),
        ChoiceOption<FolderCreationKind>(
          value: FolderCreationKind.deck,
          title: context.l10n.createDeck,
          subtitle: context.l10n.folderTypeDeckDescription,
          icon: Icons.style_outlined,
        ),
      ],
    );
}

Future<FolderCreationKind?> showFolderTypeChooserSheet(BuildContext context) => context.showAppBottomSheet<FolderCreationKind>(
    const FolderTypeChooserSheet(),
  );
