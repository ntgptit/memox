import 'package:memox/core/types/result.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';

StudySession unwrapStudySessionResult(Result<StudySession> result) =>
    switch (result) {
      Success<StudySession>(:final data) => data,
      ResultFailure<StudySession>(:final failure) => throw StateError(
        failure.message,
      ),
    };
