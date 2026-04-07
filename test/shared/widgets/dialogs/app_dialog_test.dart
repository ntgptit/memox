import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/dialogs/app_dialog.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('form variant reserves extra separation before actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const AppDialog(
                variant: AppDialogVariant.form,
                title: Text('Create'),
                content: Text('Fields'),
                actions: [SizedBox(width: 10, height: 10)],
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));

    expect(
      dialog.actionsPadding,
      const EdgeInsets.fromLTRB(
        SpacingTokens.xl,
        SpacingTokens.lg,
        SpacingTokens.xl,
        SpacingTokens.xl,
      ),
    );
    expect(
      dialog.contentPadding,
      const EdgeInsets.fromLTRB(SpacingTokens.xl, 0, SpacingTokens.xl, 0),
    );
  });

  testWidgets('standard dialog keeps the tighter default action spacing', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const AppDialog(
                title: Text('Delete'),
                content: Text('Confirm'),
                actions: [SizedBox(width: 10, height: 10)],
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));

    expect(
      dialog.actionsPadding,
      const EdgeInsets.fromLTRB(
        SpacingTokens.xl,
        0,
        SpacingTokens.xl,
        SpacingTokens.xl,
      ),
    );
  });
}
