import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/buttons/inline_text_link_button.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets(
    'InlineTextLinkButton preserves 48dp tap target without InkWell',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Center(
            child: InlineTextLinkButton(label: 'Home', onTap: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(ConstrainedBox).first);
      expect(size.height, greaterThanOrEqualTo(SizeTokens.touchTarget));
      expect(find.byType(InkWell), findsNothing);
    },
  );

  testWidgets('InlineTextLinkButton forwards taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      buildTestApp(
        home: Center(
          child: InlineTextLinkButton(
            label: 'Home',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
