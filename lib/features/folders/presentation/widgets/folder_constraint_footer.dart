import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/info_bar.dart';

class FolderConstraintFooter extends StatelessWidget {
  const FolderConstraintFooter({required this.depth, super.key});

  final int depth;

  @override
  Widget build(BuildContext context) {
    if (depth <= 3) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: SpacingTokens.lg),
        _FolderDepthWarning(depth: depth),
      ],
    );
  }
}

class _FolderDepthWarning extends StatelessWidget {
  const _FolderDepthWarning({required this.depth});

  final int depth;

  @override
  Widget build(BuildContext context) => InfoBar(
    icon: Icons.warning_amber_outlined,
    text: context.l10n.folderDepthWarning(depth),
  );
}
