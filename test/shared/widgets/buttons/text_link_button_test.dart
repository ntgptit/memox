import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('TextLinkButton preserves 48dp tap target', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Center(
          child: TextLinkButton(label: 'Retry', onTap: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(
      find.descendant(
        of: find.byType(TextLinkButton),
        matching: find.byType(InkWell),
      ),
    );
    expect(size.height, greaterThanOrEqualTo(SizeTokens.touchTarget));
  });
}
