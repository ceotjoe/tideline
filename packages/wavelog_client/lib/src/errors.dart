/// Failures talking to Wavelog, mapped from HTTP status and the API v2
/// error envelope `{error: {code, message, details}}`.
///
/// `toString()` never contains the API token or request headers.
sealed class WavelogException implements Exception {
  const new({this.code, this.serverMessage});

  /// The server's machine-readable `error.code`, if any.
  final String? code;

  /// The server's human-readable `error.message`, if any.
  final String? serverMessage;

  /// Short developer-facing name of the failure kind.
  String get kind;

  @override
  String toString() => '$kind(code: $code, message: ${serverMessage ?? '-'})';
}

/// 401: token missing, invalid, revoked or expired.
final class WavelogUnauthorized extends WavelogException {
  /// Creates the exception.
  const new({super.code, super.serverMessage});

  @override
  String get kind => 'WavelogUnauthorized';

  /// Whether the token expired (as opposed to being invalid/revoked).
  bool get isExpired => code == 'token_expired';
}

/// 403: missing scope, or a resource (e.g. station) the token can't use.
final class WavelogForbidden extends WavelogException {
  /// Creates the exception.
  const new({super.code, super.serverMessage});

  @override
  String get kind => 'WavelogForbidden';

  /// Whether the token lacks a required scope.
  bool get isInsufficientScope => code == 'insufficient_scope';
}

/// 404: resource absent, invisible to this token, or feature not present
/// on this Wavelog version.
final class WavelogNotFound extends WavelogException {
  /// Creates the exception.
  const new({super.code, super.serverMessage});

  @override
  String get kind => 'WavelogNotFound';
}

/// 400: the request was rejected as invalid.
final class WavelogValidationError extends WavelogException {
  /// Creates the exception.
  const new({super.code, super.serverMessage, this.details});

  @override
  String get kind => 'WavelogValidationError';

  /// `error.details` as sent by the server.
  final Object? details;

  /// Whether Wavelog rejected the QSO as a duplicate of an existing one
  /// (`details.duplicate`, see ADR 0008).
  bool get isDuplicate =>
      details is Map && (details! as Map).containsKey('duplicate');

  /// The request field the server rejected (`details.field`), if it named
  /// one. For contest sessions `contest` or `contest_id` means the contest
  /// is unknown or not activated by the instance admin.
  String? get rejectedField {
    final d = details;
    return d is Map && d['field'] is String ? d['field'] as String : null;
  }

  /// Whether the server refused the contest (unknown or inactive).
  bool get isContestRejected =>
      rejectedField == 'contest' || rejectedField == 'contest_id';
}

/// 409: conflicting state on the server.
final class WavelogConflict extends WavelogException {
  /// Creates the exception.
  const new({super.code, super.serverMessage});

  @override
  String get kind => 'WavelogConflict';
}

/// 429: rate limited. Retry after [retryAfter].
final class WavelogRateLimited extends WavelogException {
  /// Creates the exception.
  const new({required this.retryAfter, super.code, super.serverMessage});

  @override
  String get kind => 'WavelogRateLimited';

  /// How long the server asked us to wait.
  final Duration retryAfter;
}

/// 5xx or an unexpected status: outcome of a write is unknown.
final class WavelogServerError extends WavelogException {
  /// Creates the exception.
  const new({required this.statusCode, super.code, super.serverMessage});

  @override
  String get kind => 'WavelogServerError';

  /// HTTP status code.
  final int statusCode;
}

/// No usable response: DNS, connection, TLS or timeout. For writes, the
/// outcome is unknown.
final class WavelogNetworkError extends WavelogException {
  /// Creates the exception with a developer-facing [reason].
  const new(this.reason) : super();

  @override
  String get kind => 'WavelogNetworkError';

  /// Developer-facing description (no headers, no token).
  final String reason;

  @override
  String toString() => 'WavelogNetworkError($reason)';
}

/// The response did not match the documented API v2 shape.
final class WavelogMalformedResponse extends WavelogException {
  /// Creates the exception with a developer-facing [reason].
  const new(this.reason) : super();

  @override
  String get kind => 'WavelogMalformedResponse';

  /// What was wrong with the response.
  final String reason;

  @override
  String toString() => 'WavelogMalformedResponse($reason)';
}
