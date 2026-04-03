import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/streak_chip.dart';
import 'package:memox/shared/widgets/feedback/success_indicator.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/layout/section_container.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';
import 'package:memox/shared/widgets/progress/count_up_text.dart';
import '../../test_helpers/test_app.dart';

void main() {
  testWidgets('new shared widget primitives render with app theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: AppScaffold(
          body: ListView(
            children: [
              const AppCard(child: Text('Deck summary')),
              SectionContainer(
                title: 'Stats',
                actionLabel: 'Details',
                onAction: () {},
                child: const AppListTile(title: 'Deck', subtitle: '12 cards'),
              ),
              const SuccessIndicator(),
              const StreakChip(count: 3),
              const CountUpText(endValue: 12, style: TextStyle(), suffix: '%'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppScaffold), findsOneWidget);
    expect(find.byType(AppCard), findsOneWidget);
    expect(find.byType(SectionContainer), findsOneWidget);
    expect(find.byType(AppListTile), findsOneWidget);
    expect(find.byType(TextLinkButton), findsOneWidget);
    expect(find.byType(SuccessIndicator), findsOneWidget);
    expect(find.byType(StreakChip), findsOneWidget);
    expect(find.text('12%'), findsOneWidget);
  });
}
