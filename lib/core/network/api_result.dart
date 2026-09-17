/// Result wrapper used by every repository so screens can render
/// loading / success / empty / failure states consistently.
sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

enum FailureKind { network, unauthorized, validation, notFound, server, unknown }

class Failure<T> extends ApiResult<T> {
  const Failure(this.kind, this.message, {this.errors = const []});
  final FailureKind kind;
  final String message;
  final List<String> errors;
}

class ApiException implements Exception {
  const ApiException(this.kind, this.message);
  final FailureKind kind;
  final String message;
  @override
  String toString() => message;
}

/// Bridges [ApiResult] into Riverpod's AsyncValue error channel so screens can
/// use a single loading/error/data rendering path.
extension ApiResultX<T> on ApiResult<T> {
  T orThrow() => switch (this) {
        Success(:final data) => data,
        Failure(:final kind, :final message) => throw ApiException(kind, message),
      };
}
