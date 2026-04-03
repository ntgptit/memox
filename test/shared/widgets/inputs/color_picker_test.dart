import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/inputs/color_picker.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('ColorPicker uses 48dp choice tap target', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Center(
          child: ColorPicker(
            selectedColor: Colors.blue,
            colors: const [Colors.blue],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final choice = find.descendant(
      of: find.byType(ColorPicker),
      matching: find.byType(InkWell),
    );
    final size = tester.getSize(choice.first);
    expect(size.height, SizeTokens.touchTarget);
    expect(size.width, SizeTokens.touchTarget);
  });
}
