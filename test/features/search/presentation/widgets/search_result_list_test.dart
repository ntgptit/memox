import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/search/domain/value_objects/search_result_item.dart';
import 'package:memox/features/search/presentation/widgets/search_result_list.dart';
import 'package:memox/features/search/presentation/widgets/search_result_tile.dart';

import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('search result list groups results by destination type', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const SearchResultList(
          results: [
            FolderResult(id: 1, name: 'Korean'),
            DeckResult(id: 2, name: 'Core', folderName: 'Korean'),
            CardResult(
              id: 3,
              name: '안녕하세요',
              deckId: 2,
              back: 'Hello',
              deckName: 'Core',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Decks'), findsOneWidget);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.byType(SearchResultTile), findsNWidgets(3));
    expect(find.text('안녕하세요'), findsOneWidget);
  });
}
