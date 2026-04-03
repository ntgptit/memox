import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/database/db_constants.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/settings/domain/repositories/settings_data_repository.dart';

typedef _ImportedCard = ({
  DateTime createdAt,
  int deckId,
  double easeFactor,
  String example,
  String front,
  String back,
  String hint,
  int id,
  String imagePath,
  int interval,
  DateTime? lastReviewedAt,
  DateTime? nextReviewDate,
  int repetitions,
  CardStatus status,
  String tags,
  DateTime updatedAt,
});

typedef _ImportedDeck = ({
  int colorValue,
  DateTime createdAt,
  String description,
  int folderId,
  int id,
  String name,
  int sortOrder,
  String tags,
  DateTime updatedAt,
});

typedef _ImportedFolder = ({
  int colorValue,
  DateTime createdAt,
  int id,
  String name,
  int? parentId,
  int sortOrder,
  DateTime updatedAt,
});

final class SettingsDataRepositoryImpl implements SettingsDataRepository {
  const SettingsDataRepositoryImpl({
    required AppDatabase database,
    required AppLogger logger,
  }) : _database = database,
       _logger = logger;

  static const int exportVersion = 1;

  final AppDatabase _database;
  final AppLogger _logger;

  @override
  Future<SettingsHistoryClearSummary> clearStudyHistory() => _database.transaction(() async {
      _logger.info('Clearing study history from settings');
      final sessions = await _database.studySessionDao.getAll();
      final reviews = await _database.cardReviewDao.getAll();
      await _database.cardReviewDao.deleteAll();
      await _database.studySessionDao.deleteAll();
      return (sessionCount: sessions.length, reviewCount: reviews.length);
    });

  @override
  Future<String> exportCardsJson() async {
    final folders = await _database.folderDao.getAll();
    final decks = await _database.deckDao.getAll();
    final cards = await _database.cardDao.getAll();
    final payload = <String, Object?>{
      'version': exportVersion,
      'exportDate': DateTime.now().toIso8601String(),
      'folders': folders.map(_folderToJson).toList(),
      'decks': decks.map(_deckToJson).toList(),
      'cards': cards.map(_cardToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  @override
  Future<SettingsImportSummary> importCardsJson(String rawJson) async {
    final decoded = jsonDecode(rawJson);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid MemoX import payload.');
    }

    final version = _asInt(decoded['version']);

    if (version != exportVersion) {
      throw const FormatException('Unsupported MemoX import version.');
    }

    final folders = _parseFolders(decoded['folders']);
    final decks = _parseDecks(decoded['decks']);
    final cards = _parseCards(decoded['cards']);

    return _database.transaction(() async {
      final importedFolderIds = await _importFolders(folders);
      final importedDeckIds = await _importDecks(decks, importedFolderIds);
      final importedCards = await _importCards(cards, importedDeckIds);
      return (
        folderCount: importedFolderIds.length,
        deckCount: importedDeckIds.length,
        cardCount: importedCards,
      );
    });
  }

  Map<String, Object?> _cardToJson(CardsTableData card) => <String, Object?>{
    'id': card.id,
    'deckId': card.deckId,
    'front': card.front,
    'back': card.back,
    'hint': card.hint,
    'example': card.example,
    'tags': card.tags,
    'imagePath': card.imagePath,
    'status': card.status.index,
    'easeFactor': card.easeFactor,
    'interval': card.interval,
    'repetitions': card.repetitions,
    'nextReviewDate': card.nextReviewDate?.toIso8601String(),
    'lastReviewedAt': card.lastReviewedAt?.toIso8601String(),
    'createdAt': card.createdAt.toIso8601String(),
    'updatedAt': card.updatedAt.toIso8601String(),
  };

  Map<String, Object?> _deckToJson(DecksTableData deck) => <String, Object?>{
    'id': deck.id,
    'name': deck.name,
    'description': deck.description,
    'folderId': deck.folderId,
    'colorValue': deck.colorValue,
    'tags': deck.tags,
    'createdAt': deck.createdAt.toIso8601String(),
    'updatedAt': deck.updatedAt.toIso8601String(),
    'sortOrder': deck.sortOrder,
  };

  Map<String, Object?> _folderToJson(FoldersTableData folder) =>
      <String, Object?>{
        'id': folder.id,
        'name': folder.name,
        'parentId': folder.parentId,
        'colorValue': folder.colorValue,
        'createdAt': folder.createdAt.toIso8601String(),
        'updatedAt': folder.updatedAt.toIso8601String(),
        'sortOrder': folder.sortOrder,
      };

  Future<int> _importCards(
    List<_ImportedCard> cards,
    Set<int> importedDeckIds,
  ) async {
    var importedCount = 0;

    for (final card in cards) {
      if (!importedDeckIds.contains(card.deckId)) {
        continue;
      }

      await _database.cardDao.insertCard(
        CardsTableCompanion(
          id: Value<int>(card.id),
          deckId: Value<int>(card.deckId),
          front: Value<String>(card.front),
          back: Value<String>(card.back),
          hint: Value<String>(card.hint),
          example: Value<String>(card.example),
          tags: Value<String>(card.tags),
          imagePath: Value<String>(card.imagePath),
          status: Value<CardStatus>(card.status),
          easeFactor: Value<double>(card.easeFactor),
          interval: Value<int>(card.interval),
          repetitions: Value<int>(card.repetitions),
          nextReviewDate: Value<DateTime?>(card.nextReviewDate),
          lastReviewedAt: Value<DateTime?>(card.lastReviewedAt),
          createdAt: Value<DateTime>(card.createdAt),
          updatedAt: Value<DateTime>(card.updatedAt),
        ),
      );
      importedCount += 1;
    }

    return importedCount;
  }

  Future<Set<int>> _importDecks(
    List<_ImportedDeck> decks,
    Set<int> importedFolderIds,
  ) async {
    final importedDeckIds = <int>{};

    for (final deck in decks) {
      if (!importedFolderIds.contains(deck.folderId)) {
        continue;
      }

      await _database.deckDao.insertDeck(
        DecksTableCompanion(
          id: Value<int>(deck.id),
          name: Value<String>(deck.name),
          description: Value<String>(deck.description),
          folderId: Value<int>(deck.folderId),
          colorValue: Value<int>(deck.colorValue),
          tags: Value<String>(deck.tags),
          createdAt: Value<DateTime>(deck.createdAt),
          updatedAt: Value<DateTime>(deck.updatedAt),
          sortOrder: Value<int>(deck.sortOrder),
        ),
      );
      importedDeckIds.add(deck.id);
    }

    return importedDeckIds;
  }

  Future<Set<int>> _importFolders(List<_ImportedFolder> folders) async {
    final pending = <int, _ImportedFolder>{
      for (final folder in folders) folder.id: folder,
    };
    final importedFolderIds = <int>{};

    while (pending.isNotEmpty) {
      final ready = pending.values
          .where((folder) => _isReadyFolder(folder, importedFolderIds, pending))
          .toList();

      if (ready.isEmpty) {
        break;
      }

      for (final folder in ready) {
        await _database.folderDao.insertFolder(
          FoldersTableCompanion(
            id: Value<int>(folder.id),
            name: Value<String>(folder.name),
            parentId: Value<int?>(folder.parentId),
            colorValue: Value<int>(folder.colorValue),
            createdAt: Value<DateTime>(folder.createdAt),
            updatedAt: Value<DateTime>(folder.updatedAt),
            sortOrder: Value<int>(folder.sortOrder),
          ),
        );
        importedFolderIds.add(folder.id);
        pending.remove(folder.id);
      }
    }

    for (final folder in pending.values) {
      await _database.folderDao.insertFolder(
        FoldersTableCompanion(
          id: Value<int>(folder.id),
          name: Value<String>(folder.name),
          parentId: const Value<int?>(null),
          colorValue: Value<int>(folder.colorValue),
          createdAt: Value<DateTime>(folder.createdAt),
          updatedAt: Value<DateTime>(folder.updatedAt),
          sortOrder: Value<int>(folder.sortOrder),
        ),
      );
      importedFolderIds.add(folder.id);
    }

    return importedFolderIds;
  }

  bool _isReadyFolder(
    _ImportedFolder folder,
    Set<int> importedFolderIds,
    Map<int, _ImportedFolder> pending,
  ) {
    final parentId = folder.parentId;

    if (parentId == null) {
      return true;
    }

    if (!pending.containsKey(parentId)) {
      return true;
    }

    return importedFolderIds.contains(parentId);
  }

  DateTime _parseDateTime(Object? value, DateTime fallback) {
    if (value is! String) {
      return fallback;
    }

    return DateTime.tryParse(value) ?? fallback;
  }

  List<_ImportedCard> _parseCards(Object? value) {
    if (value is! List<Object?>) {
      return const <_ImportedCard>[];
    }

    final cards = <_ImportedCard>[];

    for (final item in value) {
      final parsed = _parseCard(item);

      if (parsed == null) {
        continue;
      }

      cards.add(parsed);
    }

    return cards;
  }

  _ImportedCard? _parseCard(Object? value) {
    final map = _asMap(value);

    if (map == null) {
      return null;
    }

    final id = _asInt(map['id']);
    final deckId = _asInt(map['deckId']);
    final front = _asString(map['front']);
    final back = _asString(map['back']);

    if (id == null || deckId == null || front == null || back == null) {
      return null;
    }

    if (_isBlank(front) || _isBlank(back)) {
      return null;
    }

    final now = DateTime.now();
    return (
      createdAt: _parseDateTime(map['createdAt'], now),
      deckId: deckId,
      easeFactor: _asDouble(map['easeFactor']) ?? DbConstants.defaultEaseFactor,
      example: _asString(map['example']) ?? '',
      front: front,
      back: back,
      hint: _asString(map['hint']) ?? '',
      id: id,
      imagePath: _asString(map['imagePath']) ?? '',
      interval: _asInt(map['interval']) ?? 0,
      lastReviewedAt: _parseNullableDateTime(map['lastReviewedAt']),
      nextReviewDate: _parseNullableDateTime(map['nextReviewDate']),
      repetitions: _asInt(map['repetitions']) ?? 0,
      status: _parseCardStatus(map['status']),
      tags: _asString(map['tags']) ?? '',
      updatedAt: _parseDateTime(map['updatedAt'], now),
    );
  }

  DateTime? _parseNullableDateTime(Object? value) {
    if (value is! String) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  CardStatus _parseCardStatus(Object? value) {
    final statusIndex = _asInt(value);

    if (statusIndex == null || statusIndex < 0) {
      return CardStatus.newCard;
    }

    if (statusIndex >= CardStatus.values.length) {
      return CardStatus.newCard;
    }

    return CardStatus.values[statusIndex];
  }

  List<_ImportedDeck> _parseDecks(Object? value) {
    if (value is! List<Object?>) {
      return const <_ImportedDeck>[];
    }

    final decks = <_ImportedDeck>[];

    for (final item in value) {
      final parsed = _parseDeck(item);

      if (parsed == null) {
        continue;
      }

      decks.add(parsed);
    }

    return decks;
  }

  _ImportedDeck? _parseDeck(Object? value) {
    final map = _asMap(value);

    if (map == null) {
      return null;
    }

    final id = _asInt(map['id']);
    final folderId = _asInt(map['folderId']);
    final name = _asString(map['name']);

    if (id == null || folderId == null || name == null) {
      return null;
    }

    if (_isBlank(name)) {
      return null;
    }

    final now = DateTime.now();
    return (
      colorValue: _asInt(map['colorValue']) ?? DbConstants.defaultColorValue,
      createdAt: _parseDateTime(map['createdAt'], now),
      description: _asString(map['description']) ?? '',
      folderId: folderId,
      id: id,
      name: name,
      sortOrder: _asInt(map['sortOrder']) ?? 0,
      tags: _asString(map['tags']) ?? '',
      updatedAt: _parseDateTime(map['updatedAt'], now),
    );
  }

  List<_ImportedFolder> _parseFolders(Object? value) {
    if (value is! List<Object?>) {
      return const <_ImportedFolder>[];
    }

    final folders = <_ImportedFolder>[];

    for (final item in value) {
      final parsed = _parseFolder(item);

      if (parsed == null) {
        continue;
      }

      folders.add(parsed);
    }

    return folders;
  }

  _ImportedFolder? _parseFolder(Object? value) {
    final map = _asMap(value);

    if (map == null) {
      return null;
    }

    final id = _asInt(map['id']);
    final name = _asString(map['name']);

    if (id == null || name == null) {
      return null;
    }

    if (_isBlank(name)) {
      return null;
    }

    final now = DateTime.now();
    return (
      colorValue: _asInt(map['colorValue']) ?? DbConstants.defaultColorValue,
      createdAt: _parseDateTime(map['createdAt'], now),
      id: id,
      name: name,
      parentId: _asInt(map['parentId']),
      sortOrder: _asInt(map['sortOrder']) ?? 0,
      updatedAt: _parseDateTime(map['updatedAt'], now),
    );
  }

  double? _asDouble(Object? value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  Map<String, Object?>? _asMap(Object? value) {
    if (value is! Map) {
      return null;
    }

    return value.map<String, Object?>(
      (key, mapValue) => MapEntry<String, Object?>(key.toString(), mapValue),
    );
  }

  bool _isBlank(String value) => value.trim().isEmpty;

  String? _asString(Object? value) {
    if (value is! String) {
      return null;
    }

    return value;
  }
}
