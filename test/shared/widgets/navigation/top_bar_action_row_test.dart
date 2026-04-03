import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/navigation/top_bar_action_row.dart';
import 'package:memox/shared/widgets/navigation/top_bar_icon_button.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('TopBarActionRow keeps the trailing action on the content grid', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          appBar: AppBar(
            actionsPadding: EdgeInsets.zero,
            actions: [
              TopBarActionRow(
                children: [
                  TopBarIconButton(
                    tooltip: 'Search',
                    onPressed: () {},
                    icon: Icons.search_outlined,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final actionButton = find.ancestor(
      of: find.byIcon(Icons.search_outlined),
      matching: find.byType(IconButton),
    );
    final actionRect = tester.getRect(actionButton);
    expect(actionRect.right, closeTo(390 - SpacingTokens.lg, 0.01));
  });
}
