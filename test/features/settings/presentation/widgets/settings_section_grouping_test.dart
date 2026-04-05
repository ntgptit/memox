import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/widgets/settings_appearance_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_data_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_group_card.dart';
import 'package:memox/features/settings/presentation/widgets/settings_notifications_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_studying_section.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

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

  testWidgets('appearance section groups theme and color controls', (
    tester,
  ) async {
    await pumpSettingsSection(
      tester,
      const SettingsAppearanceSection(settings: AppSettings.defaults),
    );

    expect(find.byType(SettingsGroupCard), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('theme mode cards center their labels', (tester) async {
    await pumpSettingsSection(
      tester,
      const SettingsAppearanceSection(settings: AppSettings.defaults),
    );

    final systemLabel = tester.widget<Text>(find.text('System'));
    expect(systemLabel.textAlign, TextAlign.center);
  });

  testWidgets('data section uses one grouped card', (tester) async {
    await pumpSettingsSection(tester, const SettingsDataSection());

    expect(find.byType(SettingsGroupCard), findsOneWidget);
    expect(find.byType(AppCard), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
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
