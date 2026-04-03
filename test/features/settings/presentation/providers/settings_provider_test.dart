import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/router/app_router.dart';
import 'package:memox/core/services/notification_service.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('theme and seed color updates apply immediately in MemoxApp', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final router = GoRouter(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          notificationServiceProvider.overrideWithValue(
            const NoopNotificationService(),
          ),
        ],
        child: const MemoxApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final initialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final notifier = container.read(settingsProvider.notifier);

    expect(initialApp.themeMode, ThemeMode.system);
    expect(
      initialApp.theme?.colorScheme.primary,
      AppTheme.light().colorScheme.primary,
    );

    await notifier.updateThemeMode(ThemeMode.dark);
    await notifier.updateSeedColor(ColorTokens.seedTeal.toARGB32());
    await tester.pumpAndSettle();

    final updatedApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(updatedApp.themeMode, ThemeMode.dark);
    expect(
      updatedApp.theme?.colorScheme.primary,
      AppTheme.light(seedColor: ColorTokens.seedTeal).colorScheme.primary,
    );
  });
}
