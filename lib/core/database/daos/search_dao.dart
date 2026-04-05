part of '../app_database.dart';

@DriftAccessor(tables: [FoldersTable, DecksTable, CardsTable])
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  static const int _limit = 20;

  Future<List<QueryRow>> searchFolders(String query) => customSelect(
    [
      'SELECT f.id, f.name,',
      '(SELECT p.name FROM folders_table p WHERE p.id = f.parent_id) AS parent_name',
      'FROM folders_table f',
      'WHERE f.name LIKE ?1',
      'ORDER BY f.name',
      'LIMIT $_limit',
    ].join(' '),
    variables: [Variable<String>('%$query%')],
    readsFrom: {foldersTable},
  ).get();

  Future<List<QueryRow>> searchDecks(String query) => customSelect(
    [
      'SELECT d.id, d.name,',
      '(SELECT f.name FROM folders_table f WHERE f.id = d.folder_id) AS folder_name',
      'FROM decks_table d',
      'WHERE d.name LIKE ?1 OR d.tags LIKE ?1',
      'ORDER BY d.name',
      'LIMIT $_limit',
    ].join(' '),
    variables: [Variable<String>('%$query%')],
    readsFrom: {decksTable, foldersTable},
  ).get();

  Future<List<QueryRow>> searchCards(String query) => customSelect(
    [
      'SELECT c.id, c.front, c.back, c.deck_id,',
      '(SELECT d.name FROM decks_table d WHERE d.id = c.deck_id) AS deck_name',
      'FROM cards_table c',
      'WHERE c.front LIKE ?1 OR c.back LIKE ?1',
      'ORDER BY c.front',
      'LIMIT $_limit',
    ].join(' '),
    variables: [Variable<String>('%$query%')],
    readsFrom: {cardsTable, decksTable},
  ).get();
}
