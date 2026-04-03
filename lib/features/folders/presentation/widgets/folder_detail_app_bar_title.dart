import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/features/folders/presentation/screens/home_screen.dart';
import 'package:memox/shared/widgets/navigation/breadcrumb_bar.dart';

class FolderDetailHeader extends StatelessWidget {
  const FolderDetailHeader({
    required this.title,
    required this.breadcrumb,
    super.key,
  });

  final String title;
  final List<FolderEntity> breadcrumb;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BreadcrumbBar(segments: _segments(context, breadcrumb)),
      const SizedBox(height: SpacingTokens.md),
      Text(
        title,
        maxLines: context.isCompact ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: context.appTextStyles.appTitle,
      ),
    ],
  );
}

List<BreadcrumbSegment> _segments(
  BuildContext context,
  List<FolderEntity> breadcrumb,
) => <BreadcrumbSegment>[
  BreadcrumbSegment(
    label: context.l10n.navHome,
    onTap: () => context.go(HomeScreen.routePath),
  ),
  ...breadcrumb.map(
    (folder) => BreadcrumbSegment(
      label: folder.name,
      onTap: () => context.push(FolderDetailScreen.routeLocation(folder.id)),
    ),
  ),
];
