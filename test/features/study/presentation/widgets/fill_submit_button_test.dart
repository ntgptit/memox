import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/features/study/presentation/widgets/fill_submit_button.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('FillSubmitButton keeps 48dp touch target', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Center(child: FillSubmitButton(enabled: true, onTap: () {})),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(
      find.descendant(
        of: find.byType(FillSubmitButton),
        matching: find.byType(InkWell),
      ),
    );
    expect(size.height, SizeTokens.touchTarget);
    expect(size.width, SizeTokens.touchTarget);
  });

  testWidgets(
    'FillSubmitButton uses the stronger primary contrast in dark mode',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: AppTheme.dark(),
          home: Center(child: FillSubmitButton(enabled: true, onTap: () {})),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(FillSubmitButton));
      final pressable = tester.widget<AppPressable>(find.byType(AppPressable));
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_forward));

      expect(pressable.color, Theme.of(context).colorScheme.primary);
      expect(icon.color, Theme.of(context).colorScheme.onPrimary);
    },
  );
}
