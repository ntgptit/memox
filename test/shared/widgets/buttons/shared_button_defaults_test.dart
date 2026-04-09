import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets(
    'PrimaryButton and SecondaryButton share the compact default height',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Column(
            children: [
              PrimaryButton(label: 'Study', onPressed: () {}),
              SecondaryButton(label: 'Later', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(FilledButton)).height,
        SizeTokens.buttonHeight,
      );
      expect(
        tester.getSize(find.byType(OutlinedButton)).height,
        SizeTokens.buttonHeight,
      );
    },
  );

  testWidgets('SecondaryButton uses the accented tonal default style', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: SecondaryButton(label: 'Later', onPressed: () {}),
      ),
    );
    await tester.pumpAndSettle();

    final theme = Theme.of(tester.element(find.byType(SecondaryButton)));
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));

    expect(
      button.style?.foregroundColor?.resolve({}),
      theme.colorScheme.primary,
    );
    expect(
      button.style?.backgroundColor?.resolve({}),
      theme.colorScheme.surfaceContainerHigh,
    );
    expect(
      button.style?.side?.resolve({})?.color.a,
      OpacityTokens.borderSubtle,
    );
  });
}
