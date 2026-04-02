import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_placeholder_view.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('statistics screen renders placeholder view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const StatisticsScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StatisticsPlaceholderView), findsOneWidget);
  });
}
