import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/database/app_database.dart';

void main() {
  late AppDatabase database;
  late FolderDao folderDao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    folderDao = database.folderDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('insert and retrieve folder', () async {
    final id = await folderDao.insertFolder(
      const FoldersTableCompanion(name: Value<String>('Test Folder')),
    );

    final folder = await folderDao.getById(id);

    expect(folder?.name, 'Test Folder');
    expect(folder?.parentId, null);
  });

  test('hasSubfolders returns true when a child exists', () async {
    final parentId = await folderDao.insertFolder(
      const FoldersTableCompanion(name: Value<String>('Parent')),
    );

    await folderDao.insertFolder(
      FoldersTableCompanion(
        name: const Value<String>('Child'),
        parentId: Value<int?>(parentId),
      ),
    );

    expect(await folderDao.hasSubfolders(parentId), isTrue);
    expect(await folderDao.hasDecks(parentId), isFalse);
  });

  test('watchRootFolders emits inserted root folders', () async {
    final stream = folderDao.watchRootFolders();

    await folderDao.insertFolder(
      const FoldersTableCompanion(name: Value<String>('Inbox')),
    );

    await expectLater(
      stream,
      emitsThrough(
        predicate<List<FoldersTableData>>(
          (List<FoldersTableData> rows) =>
              rows.any((FoldersTableData row) => row.name == 'Inbox'),
        ),
      ),
    );
  });
}
