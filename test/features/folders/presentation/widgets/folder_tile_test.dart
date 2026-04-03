import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/presentation/widgets/folder_tile.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('FolderTile displays folder data', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: FolderTile(
          folder: const FolderEntity(id: 1, name: 'Japanese N5'),
          subtitle: '2 decks · 24 cards',
          masteryPercentage: 0.5,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Japanese N5'), findsOneWidget);
    expect(find.text('2 decks · 24 cards'), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.text('50%'), findsNothing);
  });

  testWidgets('FolderTile shows 0 percent for empty mastery', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: FolderTile(
          folder: const FolderEntity(id: 1, name: 'Japanese N5'),
          subtitle: 'Empty folder',
          masteryPercentage: 0,
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('FolderTile exposes styled edit and delete actions', (
    tester,
  ) async {
    var edited = false;
    var deleted = false;

    await tester.pumpWidget(
      buildTestApp(
        home: FolderTile(
          folder: const FolderEntity(id: 1, name: 'Japanese N5'),
          subtitle: '2 decks · 24 cards',
          masteryPercentage: 0.5,
          onTap: () {},
          onEdit: () => edited = true,
          onDelete: () => deleted = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete folder'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(edited, isTrue);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete folder'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });
}
