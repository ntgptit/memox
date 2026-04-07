import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/backup/backup_data.dart';
import 'package:memox/features/settings/presentation/widgets/backup_list_sheet.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('showBackupListSheet keeps long backup lists scrollable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final backups = List<BackupInfo>.generate(
      24,
      (index) => BackupInfo(
        fileId: 'backup-$index',
        fileName: 'backup-$index.json',
        modifiedTime: DateTime(2026, 4, index + 1, 9, 30),
        sizeBytes: 1024 * (index + 1),
      ),
    );

    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showBackupListSheet(context, backups: backups),
                child: const Text('Open backups'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open backups'));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
