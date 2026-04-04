import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/buttons/app_tap_region.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('AppTapRegion forwards tap down events', (tester) async {
    Offset? tapPosition;

    await tester.pumpWidget(
      buildTestApp(
        home: Center(
          child: SizedBox(
            width: 100,
            height: 40,
            child: AppTapRegion(
              onTapDown: (details) => tapPosition = details.localPosition,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppTapRegion));
    await tester.pumpAndSettle();

    expect(tapPosition, isNotNull);
  });
}
