import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('AppCard uses the themed card surface by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Center(
          child: AppCard(
            child: SizedBox(width: 120, height: 48, child: Text('Deck')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final theme = Theme.of(tester.element(find.byType(AppCard)));
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(AppCard),
        matching: find.byType(Material),
      ),
    );

    expect(material.color, theme.cardTheme.color);
  });

  testWidgets('AppCard honors explicit background color overrides', (
    tester,
  ) async {
    const backgroundColor = Colors.red;

    await tester.pumpWidget(
      buildTestApp(
        home: const Center(
          child: AppCard(
            backgroundColor: backgroundColor,
            child: SizedBox(width: 120, height: 48, child: Text('Deck')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(AppCard),
        matching: find.byType(Material),
      ),
    );

    expect(material.color, backgroundColor);
  });
}
