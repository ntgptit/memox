import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/navigation/top_bar_icon_button.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets(
    'TopBarIconButton keeps the glyph centered inside the focus ring',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: TopBarIconButton(
                tooltip: 'Edit',
                onPressed: _noop,
                icon: Icons.edit_outlined,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonRect = tester.getRect(find.byType(IconButton));
      final iconRect = tester.getRect(find.byIcon(Icons.edit_outlined));

      expect(iconRect.center.dx, closeTo(buttonRect.center.dx, 0.01));
      expect(iconRect.center.dy, closeTo(buttonRect.center.dy, 0.01));
    },
  );
}

void _noop() {}
