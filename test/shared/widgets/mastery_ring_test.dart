import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/progress/mastery_ring.dart';
import '../../test_helpers/test_app.dart';

void main() {
  testWidgets('MasteryRing shows zero percent when requested', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const MasteryRing(
          percentage: 0,
          showZeroPercentText: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0%'), findsOneWidget);
  });
}
