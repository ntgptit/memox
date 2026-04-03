import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/features/study/presentation/widgets/fill_submit_button.dart';
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
}
