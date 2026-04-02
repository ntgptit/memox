import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/folders/presentation/widgets/folders_placeholder_view.dart';
import 'package:memox/features/settings/presentation/screens/theme_preview_screen.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  static const String routeName = 'folders';
  static const String routePath = '/';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.foldersTitle),
      actions: [
        IconButton(
          tooltip: context.l10n.themePreviewAction,
          onPressed: () => context.push(ThemePreviewScreen.routePath),
          icon: const Icon(Icons.palette_outlined),
        ),
      ],
    ),
    body: const FoldersPlaceholderView(),
  );
}
