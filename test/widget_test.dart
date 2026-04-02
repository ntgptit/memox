import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('renders folders placeholder screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWith((ref) => database)],
        child: const MemoxApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.foldersSubtitle), findsOneWidget);
  });

  testWidgets('navigates to theme preview and switches theme mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWith((ref) => database)],
        child: const MemoxApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(AppStrings.themePreviewAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.themePreviewTitle), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text(AppStrings.themeModeDark));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.dark);
  });
}
