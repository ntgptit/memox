import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/features/folders/presentation/screens/home_screen.dart';
import 'package:memox/shared/widgets/navigation/breadcrumb_bar.dart';

class FolderDetailAppBarTitle extends StatelessWidget {
  const FolderDetailAppBarTitle({
    required this.title,
    required this.breadcrumb,
    super.key,
  });

  final String title;
  final List<FolderEntity> breadcrumb;

  @override
  Widget build(BuildContext context) {
    final segments = <BreadcrumbSegment>[
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, overflow: TextOverflow.ellipsis),
        BreadcrumbBar(segments: segments),
      ],
    );
  }
}
