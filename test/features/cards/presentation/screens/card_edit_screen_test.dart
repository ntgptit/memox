import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/cards/presentation/screens/card_edit_screen.dart';
import '../../../../test_helpers/fakes/fake_flashcard_repository.dart';
import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('CardEditScreen renders existing card content', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(
            FakeFlashcardRepository(
              cards: const [
                FlashcardEntity(
                  id: 7,
                  deckId: 2,
                  front: 'Question',
                  back: 'Answer',
                ),
              ],
            ),
          ),
        ],
        child: buildTestApp(home: const CardEditScreen(deckId: 2, cardId: 7)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Card'), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);
    expect(find.text('Answer'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
