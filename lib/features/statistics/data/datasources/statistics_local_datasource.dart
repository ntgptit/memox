import 'package:memox/core/database/app_database.dart';

abstract interface class StatisticsLocalDataSource {
  Future<List<CardsTableData>> getCards();

  Future<List<CardReviewsTableData>> getReviews();

  Future<List<DecksTableData>> getDecks();

  Future<List<StudySessionsTableData>> getSessions();
}

final class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  const StatisticsLocalDataSourceImpl({
    required CardDao cardDao,
    required CardReviewDao cardReviewDao,
    required DeckDao deckDao,
    required StudySessionDao studySessionDao,
  }) : _cardDao = cardDao,
       _cardReviewDao = cardReviewDao,
       _deckDao = deckDao,
       _studySessionDao = studySessionDao;

  final CardDao _cardDao;
  final CardReviewDao _cardReviewDao;
  final DeckDao _deckDao;
  final StudySessionDao _studySessionDao;

  @override
  Future<List<CardsTableData>> getCards() => _cardDao.getAll();

  @override
  Future<List<CardReviewsTableData>> getReviews() => _cardReviewDao.getAll();

  @override
  Future<List<DecksTableData>> getDecks() => _deckDao.getAll();

  @override
  Future<List<StudySessionsTableData>> getSessions() =>
      _studySessionDao.getAll();
}
