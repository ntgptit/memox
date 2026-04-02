import 'package:memox/core/types/failure.dart';

sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => switch (this) {
    Success<T>(:final data) => success(data),
    ResultFailure<T>(failure: final errorValue) => failure(errorValue),
  };

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is ResultFailure<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    ResultFailure<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    ResultFailure<T>(:final failure) => failure,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}
