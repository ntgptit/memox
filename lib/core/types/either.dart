sealed class Either<L, R> {
  const Either();

  const factory Either.left(L value) = Left<L, R>;
  const factory Either.right(R value) = Right<L, R>;

  bool get isLeft => this is Left<L, R>;

  bool get isRight => this is Right<L, R>;
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;
}
