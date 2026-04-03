import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/navigation/top_bar_action_row.dart';
import 'package:memox/shared/widgets/navigation/top_bar_back_button.dart';
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

  testWidgets('top bar leading and trailing action insets stay symmetric', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: TopBarBackButton.balancedSlotWidth,
            leading: TopBarBackButton(onPressed: () {}, startPadding: 16),
            actionsPadding: EdgeInsets.zero,
            actions: [
              TopBarActionRow(
                children: [
                  TopBarIconButton(
                    tooltip: 'Delete',
                    onPressed: () {},
                    icon: Icons.delete_outline,
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

    final backRect = tester.getRect(
      find.ancestor(
        of: find.byIcon(Icons.arrow_back_outlined),
        matching: find.byType(IconButton),
      ),
    );
    final deleteRect = tester.getRect(
      find.ancestor(
        of: find.byIcon(Icons.delete_outline),
        matching: find.byType(IconButton),
      ),
    );
    final leftInset = backRect.left;
    final rightInset = 390 - deleteRect.right;

    expect(leftInset, closeTo(rightInset, 0.01));
  });

  testWidgets('visible back glyph stays close to trailing glyph inset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: TopBarBackButton.balancedSlotWidth,
            leading: TopBarBackButton(onPressed: () {}, startPadding: 16),
            actionsPadding: EdgeInsets.zero,
            actions: [
              TopBarActionRow(
                children: [
                  TopBarIconButton(
                    tooltip: 'Delete',
                    onPressed: () {},
                    icon: Icons.delete_outline,
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

    final backIconRect = tester.getRect(find.byIcon(Icons.arrow_back_outlined));
    final deleteIconRect = tester.getRect(find.byIcon(Icons.delete_outline));
    final leftInset = backIconRect.left;
    final rightInset = 390 - deleteIconRect.right;

    expect(leftInset, closeTo(rightInset, 1));
  });
}
