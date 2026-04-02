import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/search/presentation/screens/search_screen.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('search screen renders search bar', (tester) async {
    await tester.pumpWidget(buildTestApp(home: const SearchScreen()));

    expect(find.byType(AppSearchBar), findsOneWidget);
  });
}
