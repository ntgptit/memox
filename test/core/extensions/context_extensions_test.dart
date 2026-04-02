import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/app_theme.dart';

void main() {
  testWidgets('context extensions expose responsive and feedback helpers', (
    tester,
  ) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(700, 900),
          viewInsets: EdgeInsets.only(bottom: 12),
        ),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) {
              capturedContext = context;

              return Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () => context.showSnackBar(
                        'Theme error',
                        isError: true,
                      ),
                      child: const Text('snackbar'),
                    ),
                    TextButton(
                      onPressed: () => context.showAppBottomSheet<void>(
                        const Text('Bottom sheet'),
                      ),
                      child: const Text('sheet'),
                    ),
                    TextButton(
                      onPressed: () => context.showConfirmDialog(
                        title: 'Delete',
                        message: 'Confirm delete?',
                      ),
                      child: const Text('dialog'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(capturedContext.screenWidth, 700);
    expect(capturedContext.screenHeight, 900);
    expect(capturedContext.isKeyboardVisible, isTrue);
    expect(capturedContext.isMedium, isTrue);
    expect(capturedContext.isCompact, isFalse);
    expect(capturedContext.isExpanded, isFalse);
    expect(capturedContext.screenType.gridColumns, 2);
    expect(capturedContext.isDark, isFalse);

    await tester.tap(find.text('snackbar'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(find.text('Theme error'), findsOneWidget);
    expect(snackBar.backgroundColor, capturedContext.customColors.ratingAgain);

    await tester.tap(find.text('sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Bottom sheet'), findsOneWidget);

    Navigator.of(capturedContext).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Confirm delete?'), findsOneWidget);
    expect(find.text(AppStrings.confirmAction), findsOneWidget);
    expect(find.text(AppStrings.cancelAction), findsOneWidget);
  });
}
