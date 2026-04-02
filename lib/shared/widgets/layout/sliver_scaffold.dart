import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class SliverScaffold extends StatelessWidget {
  const SliverScaffold({
    required this.title,
    required this.slivers,
    this.expandedHeight = SizeTokens.appBarHeightLg + SpacingTokens.xxxl,
    this.fab,
    super.key,
  });

  final String title;
  final List<Widget> slivers;
  final double expandedHeight;
  final Widget? fab;

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: fab,
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: expandedHeight,
          flexibleSpace: FlexibleSpaceBar(title: Text(title)),
        ),
        ...slivers,
      ],
    ),
  );
}
