sealed class Failure {
  const Failure(this.message);

  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.notFound(String message) = NotFoundFailure;
  const factory Failure.conflict(String message) = ConflictFailure;
  const factory Failure.storage(String message) = StorageFailure;
  const factory Failure.network(String message, {int? statusCode}) =
      NetworkFailure;
  const factory Failure.unknown(String message) = UnknownFailure;

  final String message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

final class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {this.statusCode});

  final int? statusCode;
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
