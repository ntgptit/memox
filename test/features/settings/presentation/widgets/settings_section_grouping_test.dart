import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/widgets/settings_appearance_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_data_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_group_card.dart';
import 'package:memox/features/settings/presentation/widgets/settings_notifications_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_studying_section.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/inputs/color_picker.dart';

import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('studying section uses one grouped card', (tester) async {
    await pumpSettingsSection(
      tester,
      const SettingsStudyingSection(settings: AppSettings.defaults),
    );

    expect(find.byType(SettingsGroupCard), findsOneWidget);
    expect(find.byType(AppCard), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));

    final appCard = tester.widget<AppCard>(find.byType(AppCard));
    final context = tester.element(find.byType(AppCard));
    expect(
      appCard.backgroundColor,
      Theme.of(context).colorScheme.surfaceContainerLow,
    );
    expect(
      appCard.borderColor,
      Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: OpacityTokens.focus),
    );
  });

  testWidgets('notifications section groups reminder rows', (tester) async {
    await pumpSettingsSection(
      tester,
      const SettingsNotificationsSection(
        settings: AppSettings(
          studyReminder: true,
          reminderTime: TimeOfDay(hour: 20, minute: 0),
        ),
      ),
    );

    expect(find.byType(SettingsGroupCard), findsOneWidget);
    expect(find.byType(AppCard), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets(
    'appearance section keeps theme, language, and color controls in one group',
    (tester) async {
      await pumpSettingsSection(
        tester,
        const SettingsAppearanceSection(settings: AppSettings.defaults),
      );

      expect(find.byType(SettingsGroupCard), findsOneWidget);
      expect(find.byType(ColorPicker), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    },
  );

  testWidgets('theme mode cards center their labels', (tester) async {
    await pumpSettingsSection(
      tester,
      const SettingsAppearanceSection(settings: AppSettings.defaults),
    );

    final systemLabel = tester.widget<Text>(find.text('System'));
    expect(systemLabel.textAlign, TextAlign.center);
  });

  testWidgets('theme mode cards stay on one row in compact settings', (
    tester,
  ) async {
    await pumpSettingsSection(
      tester,
      const SettingsAppearanceSection(settings: AppSettings.defaults),
    );

    final systemTop = tester.getTopLeft(find.text('System')).dy;
    final lightTop = tester.getTopLeft(find.text('Light')).dy;
    final darkTop = tester.getTopLeft(find.text('Dark')).dy;

    expect(systemTop, lightTop);
    expect(lightTop, darkTop);
  });

  testWidgets('appearance header aligns with grouped content hierarchy', (
    tester,
  ) async {
    await pumpSettingsSection(
      tester,
      const SettingsAppearanceSection(settings: AppSettings.defaults),
    );

    final headerFinder = find.text('Appearance').first;
    final blockTitleFinder = find.text('Theme').first;
    final headerLeft = tester.getTopLeft(headerFinder).dx;
    final blockTitleLeft = tester.getTopLeft(blockTitleFinder).dx;
    final header = tester.widget<Text>(headerFinder);
    final context = tester.element(headerFinder);

    expect(headerLeft, blockTitleLeft);
    expect(
      header.style?.fontSize,
      Theme.of(context).textTheme.titleLarge?.fontSize,
    );
  });

  testWidgets('data section separates import/export from destructive actions', (
    tester,
  ) async {
    await pumpSettingsSection(tester, const SettingsDataSection());

    expect(find.byType(SettingsGroupCard), findsNWidgets(2));
    expect(find.byType(AppCard), findsNWidgets(2));
    expect(find.byType(Divider), findsOneWidget);
  });
}

Future<void> pumpSettingsSection(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: buildTestApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
