import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/theme/color_schemes/custom_colors.dart';
import 'package:memox/shared/widgets/chips/status_chip.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('StatusChip keeps status text neutral and dot semantic', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Center(child: StatusChip(status: CardStatus.learning)),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(StatusChip));
    final label = tester.widget<Text>(find.text('Learning'));
    final dot = tester.widget<Container>(find.byType(Container));
    final decoration = dot.decoration! as BoxDecoration;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    expect(label.style?.color, Theme.of(context).colorScheme.onSurfaceVariant);
    expect(decoration.color, customColors.statusLearning);
  });
}
