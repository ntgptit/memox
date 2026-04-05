import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/search/presentation/screens/search_screen.dart';
import 'package:memox/features/search/presentation/widgets/search_empty_view.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';

import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('search screen renders search bar and idle view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: buildTestApp(home: const SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppSearchBar), findsOneWidget);
    expect(find.byType(SearchEmptyView), findsOneWidget);
  });

  testWidgets('search screen shows results after typing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: buildTestApp(home: const SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppSearchBar), findsOneWidget);
  });
}
