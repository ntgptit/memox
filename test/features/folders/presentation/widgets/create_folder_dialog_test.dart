import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/folders/presentation/widgets/create_folder_dialog.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('CreateFolderDialog validates empty input', (tester) async {
    await tester.pumpWidget(buildTestApp(home: const CreateFolderDialog()));

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text("Folder name can't be empty"), findsOneWidget);
  });

  testWidgets('CreateFolderDialog uses the compact dialog width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestApp(home: const CreateFolderDialog()));

    expect(
      tester
          .widget<AlertDialog>(find.byType(AlertDialog))
          .constraints
          ?.maxWidth,
      360 - (SpacingTokens.lg * 2),
    );
  });
}
