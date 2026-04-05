import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/database/app_database.dart';

void main() {
  late AppDatabase database;
  late SearchDao searchDao;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    searchDao = database.searchDao;

    // Seed data
    final folderId = await database.folderDao.insertFolder(
      const FoldersTableCompanion(name: Value('Flutter Notes')),
    );
    final deckId = await database.into(database.decksTable).insert(
      DecksTableCompanion.insert(
        name: 'Dart Basics',
        description: const Value(''),
        folderId: folderId,
        colorValue: const Value(0xFF000000),
        tags: const Value('dart,programming'),
      ),
    );
    await database.into(database.cardsTable).insert(
      CardsTableCompanion.insert(
        deckId: deckId,
        front: 'What is a Future?',
        back: 'An async computation',
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('searchFolders finds folder by name', () async {
    final results = await searchDao.searchFolders('Flutter');
    expect(results, hasLength(1));
    expect(results.first.read<String>('name'), 'Flutter Notes');
  });

  test('searchDecks finds deck by name', () async {
    final results = await searchDao.searchDecks('Dart');
    expect(results, hasLength(1));
    expect(results.first.read<String>('name'), 'Dart Basics');
  });

  test('searchDecks finds deck by tags', () async {
    final results = await searchDao.searchDecks('programming');
    expect(results, hasLength(1));
    expect(results.first.read<String>('name'), 'Dart Basics');
  });

  test('searchCards finds card by front text', () async {
    final results = await searchDao.searchCards('Future');
    expect(results, hasLength(1));
    expect(results.first.read<String>('front'), 'What is a Future?');
  });

  test('searchCards finds card by back text', () async {
    final results = await searchDao.searchCards('async');
    expect(results, hasLength(1));
    expect(results.first.read<String>('back'), 'An async computation');
  });

  test('returns empty when no match', () async {
    final results = await searchDao.searchFolders('nonexistent');
    expect(results, isEmpty);
  });
}
