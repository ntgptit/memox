import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class FoldersPlaceholderView extends StatelessWidget {
  const FoldersPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => EmptyStateView(
    icon: Icons.folder_outlined,
    title: context.l10n.foldersTitle,
    subtitle: context.l10n.foldersSubtitle,
  );
}
