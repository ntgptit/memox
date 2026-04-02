import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/study/data/datasources/study_local_datasource.dart';
import 'package:memox/features/study/data/mappers/study_session_mapper.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';

final class StudyRepositoryImpl implements StudyRepository {
  const StudyRepositoryImpl({
    required StudyLocalDataSource localDataSource,
    required AppLogger logger,
  })  : _localDataSource = localDataSource,
        _logger = logger;

  final StudyLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<StudySession> startSession(String mode) async {
    _logger.info('Starting study session in mode $mode');
    final savedModel = await _localDataSource.save(
      StudySessionMapper.toModel(
        StudySession(id: 0, mode: mode),
      ),
    );
    return StudySessionMapper.toEntity(savedModel);
  }

  @override
  Stream<List<StudySession>> watchAll() {
    return _localDataSource.watchAll().map(
      (models) => models.map(StudySessionMapper.toEntity).toList(),
    );
  }
}
