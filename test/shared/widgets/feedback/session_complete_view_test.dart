import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/shared/widgets/buttons/inline_text_link_button.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/feedback/session_complete_view.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('SessionCompleteView uses the calmer shared hierarchy', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const SessionCompleteView(
          title: 'Done',
          stats: [
            SessionStat(
              label: 'Correct',
              icon: Icons.check_circle_outline,
              value: '12',
            ),
          ],
          primaryAction: SessionAction(label: 'Continue', onTap: _noop),
          secondaryAction: SessionAction(label: 'Close', onTap: _noop),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text('Done'));
    final value = tester.widget<Text>(find.text('12'));

    expect(title.style?.fontSize, TypographyTokens.titleLarge);
    expect(value.style?.fontSize, TypographyTokens.headlineMedium);
    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.byType(InlineTextLinkButton), findsOneWidget);
  });
}

void _noop() {}
