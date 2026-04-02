import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/decks/presentation/screens/decks_screen.dart';
import 'package:memox/features/decks/presentation/widgets/decks_placeholder_view.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('decks screen renders placeholder view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const DecksScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DecksPlaceholderView), findsOneWidget);
  });
}
