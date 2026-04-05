import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/search/presentation/providers/search_query_provider.dart';
import 'package:memox/features/search/presentation/widgets/search_empty_view.dart';
import 'package:memox/features/search/presentation/widgets/search_result_list.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static const String routeName = 'search';
  static const String routePath = '/search';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return AppScaffold(
      appBar: AppBar(title: Text(context.l10n.searchTitle)),
      applyHorizontalPadding: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: AppSearchBar(
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).update(value),
              hint: context.l10n.searchHint,
            ),
          ),
          Expanded(
            child: AppAsyncBuilder(
              value: resultsAsync,
              onData: (results) {
                if (results.isEmpty) {
                  return SearchEmptyView(hasQuery: query.isNotEmpty);
                }
                return SearchResultList(results: results);
              },
            ),
          ),
        ],
      ),
    );
  }
}
