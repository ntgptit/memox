import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('search variant is denser than the standard two-line tile', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Column(
          children: [
            AppListTile(
              key: Key('standard'),
              title: 'Deck',
              subtitle: 'Folder',
              leading: Icon(Icons.style_outlined),
            ),
            AppListTile(
              key: Key('search'),
              title: 'Deck',
              subtitle: 'Folder',
              leading: Icon(Icons.style_outlined),
              variant: AppListTileVariant.search,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final standardHeight = tester
        .getSize(find.byKey(const Key('standard')))
        .height;
    final searchHeight = tester.getSize(find.byKey(const Key('search'))).height;

    expect(searchHeight, lessThan(standardHeight));
  });

  testWidgets('sheet variant keeps the flat row primitive', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const AppListTile(
          title: 'Review',
          subtitle: 'Quick study mode',
          variant: AppListTileVariant.sheet,
          leading: Icon(Icons.check_circle_outline),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tile = tester.widget<AppListTile>(find.byType(AppListTile));

    expect(tile.variant, AppListTileVariant.sheet);
  });
}
