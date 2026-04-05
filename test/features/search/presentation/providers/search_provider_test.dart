import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/search/presentation/providers/search_query_provider.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());

    // Seed a folder
    await database.folderDao.insertFolder(
      const FoldersTableCompanion(name: Value('My Flutter Notes')),
    );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        searchDaoProvider.overrideWithValue(database.searchDao),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('searchResultsProvider returns empty when query is empty', () async {
    final results = await container.read(searchResultsProvider.future);
    expect(results, isEmpty);
  });

  test('searchResultsProvider returns results for matching query', () async {
    container.read(searchQueryProvider.notifier).update('Flutter');

    final results = await container.read(searchResultsProvider.future);
    expect(results, hasLength(1));
    expect(results.first.name, 'My Flutter Notes');
  });

  test('searchResultsProvider returns empty for non-matching query', () async {
    container.read(searchQueryProvider.notifier).update('nonexistent');

    final results = await container.read(searchResultsProvider.future);
    expect(results, isEmpty);
  });
}
