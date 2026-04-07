import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/services/notification_service.dart';
import 'package:memox/features/settings/presentation/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('settings screen renders settings sections and actions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(
            const NoopNotificationService(),
          ),
        ],
        child: buildTestApp(home: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Studying'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Notifications'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Data'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Data'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Export cards (JSON)'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Export cards (JSON)'), findsOneWidget);
    expect(find.text('Import from file'), findsOneWidget);
    expect(find.text('Clear study history'), findsOneWidget);
  });
}
