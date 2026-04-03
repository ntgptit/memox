import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/shared/widgets/lists/reorderable_list.dart';
import '../../test_helpers/test_app.dart';

void main() {
  testWidgets('ReorderableListWidget hides drag handle in normal mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: ReorderableListWidget<String>(
          items: const <String>['A'],
          onReorder: (oldIndex, newIndex) {},
          itemBuilder: (context, item, index) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.drag_indicator_outlined), findsNothing);
  });

  testWidgets('ReorderableListWidget uses compact drag handle visuals', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: ReorderableListWidget<String>(
          items: const <String>['A'],
          isReorderEnabled: true,
          onReorder: (oldIndex, newIndex) {},
          itemBuilder: (context, item, index) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final icon = tester.widget<Icon>(
      find.byIcon(Icons.drag_indicator_outlined),
    );
    expect(icon.size, SizeTokens.iconSm);
  });

  testWidgets('ReorderableListWidget supports pull-to-refresh in normal mode', (
    tester,
  ) async {
    var refreshed = false;

    await tester.pumpWidget(
      buildTestApp(
        home: SizedBox(
          height: 320,
          child: ReorderableListWidget<String>(
            items: const <String>['A', 'B', 'C'],
            onRefresh: () async => refreshed = true,
            onReorder: (oldIndex, newIndex) {},
            itemBuilder: (context, item, index) =>
                SizedBox(height: 80, child: Text(item)),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshed, isTrue);
  });
}
