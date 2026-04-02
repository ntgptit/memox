import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/features/decks/presentation/providers/decks_provider.dart';
import 'package:memox/features/decks/presentation/widgets/decks_placeholder_view.dart';

class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key});

  static const String routeName = 'decks';
  static const String routePath = '/decks';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(decksScreenTitleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const DecksPlaceholderView(),
    );
  }
}
