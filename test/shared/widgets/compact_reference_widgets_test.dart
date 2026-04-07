import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/shared/widgets/animations/flip_card_widget.dart';
import 'package:memox/shared/widgets/animations/pulse_widget.dart';
import 'package:memox/shared/widgets/animations/shake_widget.dart';
import 'package:memox/shared/widgets/chips/mode_chip.dart';
import 'package:memox/shared/widgets/chips/status_chip.dart';
import 'package:memox/shared/widgets/chips/tag_chip.dart';
import 'package:memox/shared/widgets/dialogs/choice_bottom_sheet.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';
import 'package:memox/shared/widgets/inputs/stepper_input.dart';
import 'package:memox/shared/widgets/inputs/tag_input_field.dart';
import 'package:memox/shared/widgets/navigation/app_bottom_nav.dart';
import 'package:memox/shared/widgets/navigation/breadcrumb_bar.dart';
import '../../test_helpers/test_app.dart';

void main() {
  testWidgets('compact widgets render with app theme', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(currentIndex: 0, onTap: (_) {}),
          body: ListView(
            children: const [
              BreadcrumbBar(
                segments: [
                  BreadcrumbSegment(label: 'Home'),
                  BreadcrumbSegment(label: 'Deck'),
                ],
              ),
              StatusChip(status: CardStatus.learning),
              ModeChip(mode: StudyMode.review, isSelected: true),
              TagChip(label: 'Grammar'),
              FlipCardWidget(
                front: Text('Front'),
                back: Text('Back'),
                isFlipped: false,
              ),
              ShakeWidget(isShaking: false, child: Text('Shake')),
              PulseWidget(child: Text('Pulse')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(find.byType(BreadcrumbBar), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
  });

  testWidgets('search bar debounces and clear resets query', (tester) async {
    final values = <String>[];

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppSearchBar(
            onChanged: values.add,
            variant: AppSearchBarVariant.page,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'deck');
    await tester.pump(const Duration(milliseconds: 299));
    expect(values, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(values.single, 'deck');

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(values.last, '');
  });

  testWidgets('stepper input clamps and tag input adds suggestions', (
    tester,
  ) async {
    var value = 1;
    var tags = <String>['Core'];

    await tester.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                StepperInput(
                  value: value,
                  min: 1,
                  max: 3,
                  step: 1,
                  label: 'Cards',
                  onChanged: (next) => setState(() => value = next),
                ),
                TagInputField(
                  tags: tags,
                  suggestions: const ['Core', 'Grammar', 'Listening'],
                  onChanged: (next) => setState(() => tags = next),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Gra');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grammar'));
    await tester.pumpAndSettle();
    expect(find.text('Grammar'), findsOneWidget);
  });

  testWidgets('choice bottom sheet returns selected value', (tester) async {
    String? result;

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showChoiceBottomSheet<String>(
                  context,
                  title: 'Mode',
                  options: const [
                    ChoiceOption(value: 'review', title: 'Review'),
                    ChoiceOption(value: 'match', title: 'Match'),
                  ],
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Match'));
    await tester.pumpAndSettle();
    expect(result, 'match');
  });
}
