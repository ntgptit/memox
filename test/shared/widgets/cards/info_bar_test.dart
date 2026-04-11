import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/cards/info_bar.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('InfoBar maps the message into an accented shared card', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const InfoBar(
          icon: Icons.info_outline,
          text: 'Study sync is active',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(InfoBar));
    final theme = Theme.of(context);
    final card = tester.widget<AppCard>(find.byType(AppCard));

    expect(card.backgroundColor, theme.colorScheme.surfaceContainerLow);
    expect(card.leftBorderColor, theme.colorScheme.primary);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.text('Study sync is active'), findsOneWidget);
    expect(card.backgroundColor?.a, greaterThan(1 - OpacityTokens.softTint));
  });
}
