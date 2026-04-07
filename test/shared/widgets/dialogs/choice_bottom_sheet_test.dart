import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/dialogs/choice_bottom_sheet.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('showChoiceBottomSheet keeps long option lists scrollable', (
    tester,
  ) async {
    final options = List<ChoiceOption<String>>.generate(
      24,
      (index) => ChoiceOption<String>(
        value: '$index',
        title: 'Option $index',
        subtitle: 'Supporting text $index',
        icon: Icons.label_outline,
      ),
    );

    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              unawaited(
                showChoiceBottomSheet<String>(
                  context,
                  title: 'Choose option',
                  options: options,
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
