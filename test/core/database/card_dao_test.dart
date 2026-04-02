import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/card_status.dart';

void main() {
  late AppDatabase database;
  late CardDao cardDao;
  late int deckId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    cardDao = database.cardDao;
    final folderId = await database.folderDao.insertFolder(
      const FoldersTableCompanion(name: Value<String>('Folder')),
    );
    deckId = await database.deckDao.insertDeck(
      DecksTableCompanion(
        name: const Value<String>('Deck'),
        folderId: Value<int>(folderId),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('getDueCards returns due and new cards only', () async {
    await cardDao.insertCard(
      CardsTableCompanion(
        deckId: Value<int>(deckId),
        front: const Value<String>('Due'),
        back: const Value<String>('Back'),
        status: const Value<CardStatus>(CardStatus.reviewing),
        nextReviewDate: Value<DateTime?>(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
    );
    await cardDao.insertCard(
      CardsTableCompanion(
        deckId: Value<int>(deckId),
        front: const Value<String>('New'),
        back: const Value<String>('Back'),
        status: const Value<CardStatus>(CardStatus.newCard),
      ),
    );
    await cardDao.insertCard(
      CardsTableCompanion(
        deckId: Value<int>(deckId),
        front: const Value<String>('Future'),
        back: const Value<String>('Back'),
        status: const Value<CardStatus>(CardStatus.reviewing),
        nextReviewDate: Value<DateTime?>(
          DateTime.now().add(const Duration(days: 1)),
        ),
      ),
    );

    final dueCards = await cardDao.getDueCards(deckId: deckId, limit: 10);

    expect(dueCards, hasLength(2));
    expect(
      dueCards.map((CardsTableData row) => row.front),
      containsAll(<String>['Due', 'New']),
    );
  });
}
