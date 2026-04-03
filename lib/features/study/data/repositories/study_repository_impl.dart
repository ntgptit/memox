import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/study/data/datasources/study_local_datasource.dart';
import 'package:memox/features/study/data/mappers/study_session_mapper.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';

final class StudyRepositoryImpl implements StudyRepository {
  const StudyRepositoryImpl({
    required StudyLocalDataSource localDataSource,
    required AppLogger logger,
  }) : _localDataSource = localDataSource,
       _logger = logger;

  final StudyLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<StudySession> completeSession(StudySession session) async {
    _logger.info(
      'Completing study session ${session.id} in mode ${session.mode}',
    );
    final savedRow = await _localDataSource.save(session.toCompanion());
    return savedRow.toEntity();
  }

  @override
  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  }) async {
    _logger.info('Starting study session for deck $deckId in mode $mode');
    final savedRow = await _localDataSource.save(
      StudySession(
        id: 0,
        deckId: deckId,
        mode: mode,
        startedAt: DateTime.now(),
      ).toCompanion(),
    );
    return savedRow.toEntity();
  }

  @override
  Stream<List<StudySession>> watchAll() => _localDataSource.watchAll().map(
    (rows) => rows.map((row) => row.toEntity()).toList(),
  );
}
