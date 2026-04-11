import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/inputs/app_switch_tile.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets(
    'AppCardSwitchTile accents the enabled state with the primary rail',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: AppCardSwitchTile(
            label: 'Sync',
            value: true,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AppCardSwitchTile));
      final theme = Theme.of(context);
      final card = tester.widget<AppCard>(find.byType(AppCard));

      expect(card.leftBorderColor, theme.colorScheme.primary);
      expect(
        card.borderColor,
        theme.colorScheme.primary.withValues(alpha: OpacityTokens.borderSubtle),
      );
    },
  );

  testWidgets('AppCardSwitchTile keeps the neutral border when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: AppCardSwitchTile(label: 'Sync', value: false, onChanged: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(AppCardSwitchTile));
    final theme = Theme.of(context);
    final card = tester.widget<AppCard>(find.byType(AppCard));

    expect(card.leftBorderColor, isNull);
    expect(
      card.borderColor,
      theme.colorScheme.outlineVariant.withValues(
        alpha: OpacityTokens.borderSubtle,
      ),
    );
  });
}
