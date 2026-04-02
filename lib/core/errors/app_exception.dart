import 'package:memox/core/types/failure.dart';

sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  Failure toFailure();
}

final class ValidationException extends AppException {
  const ValidationException(super.message);

  @override
  Failure toFailure() => Failure.validation(message);
}

final class StorageException extends AppException {
  const StorageException(super.message);

  @override
  Failure toFailure() => Failure.storage(message);
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {this.statusCode});

  final int? statusCode;

  @override
  Failure toFailure() => Failure.network(message, statusCode: statusCode);
}

final class UnknownAppException extends AppException {
  const UnknownAppException(super.message);

  @override
  Failure toFailure() => Failure.unknown(message);
}
