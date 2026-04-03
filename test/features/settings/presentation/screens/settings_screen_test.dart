import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/services/database_export_service.dart';
import 'package:memox/features/settings/presentation/screens/settings_screen.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_mode_selector.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('settings screen renders theme controls', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: buildTestApp(home: const SettingsScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ThemeModeSelector), findsOneWidget);
  });

  testWidgets('settings screen exports database when supported', (
    tester,
  ) async {
    final service = _FakeDatabaseExportService(
      result: const DatabaseExportSuccess(fileName: 'memox_database.sqlite'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseExportServiceProvider.overrideWithValue(service)],
        child: buildTestApp(home: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Export SQLite database'), findsOneWidget);

    await tester.tap(find.text('Export SQLite database'));
    await tester.pumpAndSettle();

    expect(service.exportCallCount, 1);
    expect(
      find.text('Database exported as memox_database.sqlite'),
      findsOneWidget,
    );
  });
}

final class _FakeDatabaseExportService implements DatabaseExportService {
  _FakeDatabaseExportService({required this.result});

  @override
  final bool isSupported = true;

  final DatabaseExportResult result;
  int exportCallCount = 0;

  @override
  Future<DatabaseExportResult> exportCurrentDatabase() async {
    exportCallCount += 1;
    return result;
  }
}
