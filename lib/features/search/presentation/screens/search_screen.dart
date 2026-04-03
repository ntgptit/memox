import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/search/presentation/widgets/search_placeholder_view.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const String routeName = 'search';
  static const String routePath = '/search';

  @override
  Widget build(BuildContext context) => AppScaffold(
    applyHorizontalPadding: false,
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: AppSearchBar(onChanged: _handleSearchChanged),
        ),
        const Expanded(child: SearchPlaceholderView()),
      ],
    ),
  );

  void _handleSearchChanged(String value) {}
}
