import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/features/folders/presentation/providers/folders_provider.dart';
import 'package:memox/features/folders/presentation/widgets/folders_placeholder_view.dart';
import 'package:memox/features/settings/presentation/screens/theme_preview_screen.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  static const String routeName = 'folders';
  static const String routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(foldersScreenTitleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: AppStrings.themePreviewAction,
            onPressed: () => context.push(ThemePreviewScreen.routePath),
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
      ),
      body: const FoldersPlaceholderView(),
    );
  }
}
