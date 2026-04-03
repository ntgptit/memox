import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/decks/presentation/widgets/decks_placeholder_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/app_root_bottom_nav.dart';

class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  static const String routeName = 'decks';
  static const String routePath = '/decks';

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: Text(context.l10n.decksTitle)),
    bottomNavigationBar: const AppRootBottomNav(currentIndex: 1),
    body: const DecksPlaceholderView(),
  );
}
