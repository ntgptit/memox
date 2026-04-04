import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/buttons/inline_text_link_button.dart';
import 'package:memox/shared/widgets/navigation/breadcrumb_bar.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('BreadcrumbBar keeps segment tap target at 48dp', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const BreadcrumbBar(
          segments: [
            BreadcrumbSegment(label: 'Home'),
            BreadcrumbSegment(label: 'Deck'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InlineTextLinkButton), findsNWidgets(2));
    expect(find.byType(InkWell), findsNothing);
    final size = tester.getSize(find.byType(InlineTextLinkButton).first);
    expect(size.height, greaterThanOrEqualTo(SizeTokens.touchTarget));
  });
}
