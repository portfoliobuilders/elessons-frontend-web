import 'api_exception.dart';

/// A tiny functional result type: either [Success] with data, or [Failure]
/// carrying an [ApiException]. Repositories return `Result<T>` so providers can
/// branch on outcome without try/catch littered through the UI layer.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// The data if this is a success, otherwise null.
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// The error if this is a failure, otherwise null.
  ApiException? get errorOrNull =>
      this is Failure<T> ? (this as Failure<T>).error : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    return failure((self as Failure<T>).error);
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final ApiException error;
}
