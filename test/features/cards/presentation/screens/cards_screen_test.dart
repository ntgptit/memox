import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/presentation/screens/cards_screen.dart';
import 'package:memox/features/cards/presentation/widgets/cards_placeholder_view.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('cards screen renders placeholder view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const CardsScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CardsPlaceholderView), findsOneWidget);
  });
}
