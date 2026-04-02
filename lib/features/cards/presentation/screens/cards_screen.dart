import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/features/cards/presentation/providers/cards_provider.dart';
import 'package:memox/features/cards/presentation/widgets/cards_placeholder_view.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  static const String routeName = 'cards';
  static const String routePath = '/cards';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(cardsScreenTitleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const CardsPlaceholderView(),
    );
  }
}
