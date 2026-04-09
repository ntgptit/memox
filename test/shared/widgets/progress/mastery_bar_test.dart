import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/color_schemes/custom_colors.dart';
import 'package:memox/shared/widgets/progress/mastery_bar.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('MasteryBar uses the shared mastery track and fill colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Center(
          child: SizedBox(width: 160, child: MasteryBar(percentage: 0.5)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MasteryBar));
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final track = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(MasteryBar),
        matching: find.byType(ColoredBox),
      ),
    );
    final fill = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(MasteryBar),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = fill.decoration as BoxDecoration;

    expect(track.color, customColors.masteryFixed);
    expect(decoration.color, customColors.mastery);
  });
}
