sealed class Result<T, E> {
  const Result();
}

final class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

final class Failure<T, E> extends Result<T, E> {
  final E exception;
  final dynamic data;
  const Failure(this.exception, {this.data});
}

class ApiError {
  final String errorCode;
  ApiError(this.errorCode);
}
