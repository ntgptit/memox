import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/cards/presentation/widgets/cards_placeholder_view.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  static const String routeName = 'cards';
  static const String routePath = '/cards';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.cardsTitle)),
    body: const CardsPlaceholderView(),
  );
}
