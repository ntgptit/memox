import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/inputs/app_search_bar.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('page variant keeps the neutral page search fill', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: AppSearchBar(
            onChanged: _noop,
            variant: AppSearchBarVariant.page,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(AppSearchBar));
    final field = tester.widget<TextField>(find.byType(TextField));

    expect(
      field.decoration?.fillColor,
      Theme.of(context).colorScheme.surfaceContainerHigh,
    );
    expect(field.decoration?.contentPadding, isNull);
  });

  testWidgets(
    'toolbar variant uses the stronger toolbar fill and compact padding',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const Scaffold(
            body: AppSearchBar(
              onChanged: _noop,
              variant: AppSearchBarVariant.toolbar,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AppSearchBar));
      final field = tester.widget<TextField>(find.byType(TextField));

      expect(
        field.decoration?.fillColor,
        Theme.of(context).colorScheme.surfaceContainerHighest,
      );
      expect(field.decoration?.contentPadding, isNotNull);
    },
  );
}

void _noop(String _) {}
