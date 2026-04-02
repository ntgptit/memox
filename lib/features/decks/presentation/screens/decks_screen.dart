import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/decks/presentation/widgets/decks_placeholder_view.dart';

class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  static const String routeName = 'decks';
  static const String routePath = '/decks';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.decksTitle)),
    body: const DecksPlaceholderView(),
  );
}
