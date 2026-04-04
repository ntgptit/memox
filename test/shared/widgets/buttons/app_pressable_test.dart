import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('AppPressable keeps a 48dp minimum tap target', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Center(child: AppPressable(child: Text('Open'))),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byType(InkWell));
    expect(size.height, greaterThanOrEqualTo(SizeTokens.touchTarget));
  });

  testWidgets('AppPressable forwards taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      buildTestApp(
        home: Center(
          child: AppPressable(
            onTap: () => tapped = true,
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
