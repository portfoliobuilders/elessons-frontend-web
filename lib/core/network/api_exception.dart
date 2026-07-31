/// A single, typed error surface for the whole app.
///
/// Every failure — HTTP status, socket drop, timeout, bad JSON — becomes an
/// [ApiException] with a human-readable [message] the UI can show directly,
/// plus a [kind] the app can branch on (e.g. force logout on [unauthorized]).
enum ApiErrorKind {
  badRequest, // 400
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  conflict, // 409
  validation, // 422
  tooManyRequests, // 429
  server, // 500 / 503 …
  noInternet, // SocketException
  timeout, // TimeoutException
  parsing, // malformed JSON
  unknown,
}

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.kind = ApiErrorKind.unknown,
    this.details,
  });

  final String message;
  final int? statusCode;
  final ApiErrorKind kind;

  /// Field-level validation errors when the backend returns a 422/400 with an
  /// array of messages (NestJS ValidationPipe).
  final List<String>? details;

  bool get isUnauthorized => kind == ApiErrorKind.unauthorized;
  bool get isNetwork =>
      kind == ApiErrorKind.noInternet || kind == ApiErrorKind.timeout;

  /// Build the right exception from an HTTP status code and a decoded body.
  /// NestJS error bodies look like `{ statusCode, message, error }` where
  /// `message` is either a string or a list of validation strings.
  factory ApiException.fromResponse(int status, dynamic body) {
    String message = _defaultMessageFor(status);
    List<String>? details;

    if (body is Map) {
      final raw = body['message'] ?? body['error'];
      if (raw is String && raw.trim().isNotEmpty) {
        message = raw;
      } else if (raw is List && raw.isNotEmpty) {
        details = raw.map((e) => e.toString()).toList();
        message = details.first;
      }
    }

    return ApiException(
      message,
      statusCode: status,
      kind: _kindFor(status),
      details: details,
    );
  }

  static ApiErrorKind _kindFor(int status) {
    switch (status) {
      case 400:
        return ApiErrorKind.badRequest;
      case 401:
        return ApiErrorKind.unauthorized;
      case 403:
        return ApiErrorKind.forbidden;
      case 404:
        return ApiErrorKind.notFound;
      case 409:
        return ApiErrorKind.conflict;
      case 422:
        return ApiErrorKind.validation;
      case 429:
        return ApiErrorKind.tooManyRequests;
      default:
        return status >= 500 ? ApiErrorKind.server : ApiErrorKind.unknown;
    }
  }

  static String _defaultMessageFor(int status) {
    switch (status) {
      case 400:
        return 'Something in that request wasn\'t right. Please check and try again.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You don\'t have access to this yet.';
      case 404:
        return 'We couldn\'t find what you were looking for.';
      case 409:
        return 'That already exists.';
      case 422:
        return 'Please check the details you entered.';
      case 429:
        return 'Too many attempts. Please wait a moment and try again.';
      case 500:
        return 'Something went wrong on our end. Please try again shortly.';
      case 503:
        return 'The service is temporarily unavailable. Please try again shortly.';
      default:
        return 'Unexpected error (HTTP $status).';
    }
  }

  // Convenience constructors for non-HTTP failures.
  factory ApiException.noInternet() => ApiException(
        'No internet connection. Please check your network and try again.',
        kind: ApiErrorKind.noInternet,
      );

  factory ApiException.timeout() => ApiException(
        'The request took too long. Please try again.',
        kind: ApiErrorKind.timeout,
      );

  factory ApiException.parsing([String? detail]) => ApiException(
        'We received an unexpected response from the server.',
        kind: ApiErrorKind.parsing,
        details: detail == null ? null : [detail],
      );

  @override
  String toString() => 'ApiException($statusCode, $kind): $message';
}
