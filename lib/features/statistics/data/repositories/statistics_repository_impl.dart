import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/utils/date_utils.dart';
import 'package:memox/features/cards/data/mappers/flashcard_mapper.dart';
import 'package:memox/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:memox/features/statistics/data/mappers/statistics_mode_usage_mapper.dart';
import 'package:memox/features/statistics/domain/entities/daily_activity.dart';
import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/features/statistics/domain/entities/mastery_breakdown.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';

final class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({
    required StatisticsLocalDataSource localDataSource,
    required AppLogger logger,
    DateTime Function()? now,
  }) : _localDataSource = localDataSource,
       _logger = logger,
       _now = now ?? DateTime.now;

  final StatisticsLocalDataSource _localDataSource;
  final AppLogger _logger;
  final DateTime Function() _now;

  @override
  Future<List<DifficultCard>> getDifficultCards({
    required DateRange range,
    int limit = 5,
  }) async {
    _logger.info('Loading difficult cards for range ${range.name}');
    final data = await _loadData();
    final reviews = _reviewsInRange(data.reviews, range);

    if (reviews.isEmpty) {
      return const <DifficultCard>[];
    }

    final cardsById = <int, CardsTableData>{
      for (final card in data.cards) card.id: card,
    };
    final decksById = <int, DecksTableData>{
      for (final deck in data.decks) deck.id: deck,
    };
    final statsByCardId = <int, ({int total, int correct, int again})>{};

    for (final review in reviews) {
      if (!cardsById.containsKey(review.cardId)) {
        continue;
      }

      final current =
          statsByCardId[review.cardId] ?? (total: 0, correct: 0, again: 0);
      statsByCardId[review.cardId] = (
        total: current.total + 1,
        correct: current.correct + (review.isCorrect ? 1 : 0),
        again: current.again + (review.rating == 0 ? 1 : 0),
      );
    }

    final difficultCards =
        <({DifficultCard item, int againCount, int total})>[];

    for (final entry in statsByCardId.entries) {
      final stats = entry.value;

      if (stats.total == 0) {
        continue;
      }

      final card = cardsById[entry.key];

      if (card == null) {
        continue;
      }

      difficultCards.add((
        item: (
          card: card.toEntity(),
          deckName: decksById[card.deckId]?.name ?? '',
          accuracy: (stats.correct / stats.total) * 100,
        ),
        againCount: stats.again,
        total: stats.total,
      ));
    }

    difficultCards.sort((left, right) {
      final accuracyCompare = left.item.accuracy.compareTo(right.item.accuracy);

      if (accuracyCompare != 0) {
        return accuracyCompare;
      }

      final againCompare = right.againCount.compareTo(left.againCount);

      if (againCompare != 0) {
        return againCompare;
      }

      return right.total.compareTo(left.total);
    });

    return difficultCards.take(limit).map((entry) => entry.item).toList();
  }

  @override
  Future<MasteryBreakdown> getMasteryBreakdown() async {
    _logger.info('Loading mastery breakdown');
    final cards = await _localDataSource.getCards();
    var known = 0;
    var learning = 0;
    var newCards = 0;

    for (final card in cards) {
      if (card.status == CardStatus.mastered) {
        known++;
        continue;
      }

      if (card.status == CardStatus.newCard) {
        newCards++;
        continue;
      }

      learning++;
    }

    return (
      known: known,
      learning: learning,
      newCards: newCards,
      total: cards.length,
    );
  }

  @override
  Future<Map<StudyMode, double>> getModeUsage(DateRange range) async {
    _logger.info('Loading mode usage for range ${range.name}');
    final sessions = _sessionsInRange(
      await _localDataSource.getSessions(),
      range,
    );
    final total = sessions.length;

    if (total == 0) {
      return zeroStatisticsModeUsage();
    }

    final counts = <StudyMode, int>{
      for (final mode in StudyMode.values) mode: 0,
    };

    for (final session in sessions) {
      counts.update(session.mode, (value) => value + 1);
    }

    return {
      for (final mode in StudyMode.values) mode: (counts[mode]! / total) * 100,
    };
  }

  @override
  Future<int> getStreak() async {
    _logger.info('Loading streak');
    final sessions = _completedSessions(await _localDataSource.getSessions());
    final studyDays = sessions
        .map((session) => AppDateUtils.startOfDay(session.completedAt!))
        .toSet();
    final today = AppDateUtils.startOfDay(_now());

    if (!studyDays.contains(today)) {
      return 0;
    }

    var streak = 0;
    var cursor = today;

    while (studyDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  @override
  Future<List<DailyActivity>> getWeeklyActivity() async {
    _logger.info('Loading weekly activity');
    final sessions = _completedSessions(await _localDataSource.getSessions());
    final today = AppDateUtils.startOfDay(_now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final sessionsByDay = <DateTime, List<StudySessionsTableData>>{};

    for (final session in sessions) {
      final date = AppDateUtils.startOfDay(session.completedAt!);
      final offset = date.difference(weekStart).inDays;

      if (offset < 0 || offset > 6) {
        continue;
      }

      (sessionsByDay[date] ??= <StudySessionsTableData>[]).add(session);
    }

    return List<DailyActivity>.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final daySessions =
          sessionsByDay[date] ?? const <StudySessionsTableData>[];

      return (
        date: date,
        cardsStudied: daySessions.fold<int>(
          0,
          (sum, session) => sum + session.totalCards,
        ),
        minutes: _minutesFromSeconds(
          daySessions.fold<int>(
            0,
            (sum, session) => sum + session.durationSeconds,
          ),
        ),
      );
    });
  }

  Future<
    ({
      List<CardsTableData> cards,
      List<DecksTableData> decks,
      List<CardReviewsTableData> reviews,
      List<StudySessionsTableData> sessions,
    })
  >
  _loadData() async {
    final cardsFuture = _localDataSource.getCards();
    final decksFuture = _localDataSource.getDecks();
    final reviewsFuture = _localDataSource.getReviews();
    final sessionsFuture = _localDataSource.getSessions();

    return (
      cards: await cardsFuture,
      decks: await decksFuture,
      reviews: await reviewsFuture,
      sessions: await sessionsFuture,
    );
  }

  List<StudySessionsTableData> _completedSessions(
    List<StudySessionsTableData> sessions,
  ) => sessions.where((session) => session.completedAt != null).toList();

  List<CardReviewsTableData> _reviewsInRange(
    List<CardReviewsTableData> reviews,
    DateRange range,
  ) => reviews
      .where((review) => range.includes(review.reviewedAt, _now()))
      .toList();

  List<StudySessionsTableData> _sessionsInRange(
    List<StudySessionsTableData> sessions,
    DateRange range,
  ) => _completedSessions(
    sessions,
  ).where((session) => range.includes(session.completedAt!, _now())).toList();

  int _minutesFromSeconds(int seconds) => (seconds / 60).round();
}
