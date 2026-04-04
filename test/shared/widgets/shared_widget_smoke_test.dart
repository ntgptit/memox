import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';
import 'package:memox/shared/widgets/buttons/app_tap_region.dart';
import 'package:memox/shared/widgets/buttons/inline_text_link_button.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/streak_chip.dart';
import 'package:memox/shared/widgets/feedback/offline_state_view.dart';
import 'package:memox/shared/widgets/feedback/success_indicator.dart';
import 'package:memox/shared/widgets/feedback/unauthorized_state_view.dart';
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
              AppPressable(onTap: () {}, child: const Text('Open')),
              AppTapRegion(
                onTap: () {},
                child: const SizedBox(width: 16, height: 16),
              ),
              InlineTextLinkButton(label: 'Home', onTap: () {}),
              const SuccessIndicator(),
              const OfflineStateView(),
              const UnauthorizedStateView(),
              const StreakChip(count: 3),
              const CountUpText(endValue: 12, style: TextStyle(), suffix: '%'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('12%', skipOffstage: false),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppScaffold), findsOneWidget);
    expect(find.byType(AppCard, skipOffstage: false), findsOneWidget);
    expect(find.byType(SectionContainer, skipOffstage: false), findsOneWidget);
    expect(find.byType(AppListTile, skipOffstage: false), findsOneWidget);
    expect(find.byType(AppPressable), findsWidgets);
    expect(find.byType(AppTapRegion), findsWidgets);
    expect(find.byType(InlineTextLinkButton, skipOffstage: false), findsOneWidget);
    expect(find.byType(TextLinkButton, skipOffstage: false), findsOneWidget);
    expect(find.byType(SuccessIndicator, skipOffstage: false), findsOneWidget);
    expect(find.byType(OfflineStateView, skipOffstage: false), findsOneWidget);
    expect(
      find.byType(UnauthorizedStateView, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byType(StreakChip, skipOffstage: false), findsOneWidget);
    expect(find.text('12%', skipOffstage: false), findsOneWidget);
  });
}
