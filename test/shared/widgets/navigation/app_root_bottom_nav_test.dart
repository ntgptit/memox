import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/features/decks/presentation/screens/decks_screen.dart';
import 'package:memox/features/folders/presentation/screens/home_screen.dart';
import 'package:memox/features/settings/presentation/screens/settings_screen.dart';
import 'package:memox/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/shared/widgets/navigation/app_bottom_nav.dart';
import 'package:memox/shared/widgets/navigation/app_root_bottom_nav.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('app root bottom nav renders shared destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          bottomNavigationBar: AppRootBottomNav(currentIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('app root bottom nav routes to selected root screen', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: HomeScreen.routePath,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: HomeScreen.routePath,
                  builder: (context, state) =>
                      const _CounterScreen(currentIndex: 0, label: 'Home'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: DecksScreen.routePath,
                  builder: (context, state) =>
                      const _StaticScreen(currentIndex: 1, label: 'Decks'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: StatisticsScreen.routePath,
                  builder: (context, state) =>
                      const _StaticScreen(currentIndex: 2, label: 'Stats'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: SettingsScreen.routePath,
                  builder: (context, state) =>
                      const _StaticScreen(currentIndex: 3, label: 'Settings'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Increment'));
    await tester.pumpAndSettle();
    expect(find.text('Count: 1'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    expect(find.text('Decks'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Count: 1'), findsOneWidget);
  });
}

class _CounterScreen extends StatefulWidget {
  const _CounterScreen({required this.currentIndex, required this.label});

  final int currentIndex;
  final String label;

  @override
  State<_CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<_CounterScreen> {
  var _count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: AppRootBottomNav(currentIndex: widget.currentIndex),
    body: Column(
      children: [
        Text(widget.label),
        Text('Count: $_count'),
        TextButton(
          onPressed: () {
            setState(() {
              _count++;
            });
          },
          child: const Text('Increment'),
        ),
      ],
    ),
  );
}

class _StaticScreen extends StatelessWidget {
  const _StaticScreen({required this.currentIndex, required this.label});

  final int currentIndex;
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: AppRootBottomNav(currentIndex: currentIndex),
    body: Text(label),
  );
}
