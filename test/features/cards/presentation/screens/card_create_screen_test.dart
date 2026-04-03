import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/presentation/screens/card_create_screen.dart';
import 'package:memox/features/cards/presentation/widgets/card_editor_view.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('CardCreateScreen validates empty fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: buildTestApp(home: const CardCreateScreen(deckId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text("Front can't be empty"), findsOneWidget);
    expect(find.text("Back can't be empty"), findsOneWidget);
  });

  testWidgets('CardCreateScreen batch mode uses segmented separator selector', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: buildTestApp(
          home: const CardCreateScreen(
            deckId: 1,
            initialMode: CardEditorMode.batch,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((widget) => widget is SegmentedButton<String>),
      findsOneWidget,
    );
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Separator'), findsOneWidget);
    expect(find.text('No valid cards parsed yet'), findsOneWidget);
  });
}
