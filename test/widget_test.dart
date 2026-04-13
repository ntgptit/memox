import 'package:flutter_test/flutter_test.dart';

import 'package:memox/main.dart';

void main() {
  testWidgets('shows rebuild baseline copy', (tester) async {
    await tester.pumpWidget(const MemoxApp());

    expect(find.text('MemoX'), findsOneWidget);
    expect(
      find.text('The app has been reset to a clean Flutter baseline.'),
      findsOneWidget,
    );
    expect(
      find.text('Start the rebuild from lib/ with a new architecture and UI.'),
      findsOneWidget,
    );
  });
}
