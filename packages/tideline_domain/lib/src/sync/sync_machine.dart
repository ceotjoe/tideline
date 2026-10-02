import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:tideline_domain/src/sync/sync_state.dart';

/// Why a sync step did not succeed. The UI maps each value to a localised,
/// plain-language explanation; the server's own text is kept separately.
enum SyncProblem {
  /// No connection or the server did not answer.
  network,

  /// The server asked us to slow down.
  rateLimited,

  /// The server failed (5xx); outcome unknown.
  serverError,

  /// The server rejected the QSO's data.
  invalidData,

  /// The token may not use the QSO's station location.
  stationNotAllowed,

  /// The token lacks a required permission.
  missingPermission,

  /// The token is invalid or revoked.
  tokenInvalid,

  /// The token expired.
  tokenExpired,

  /// The change touches fields Wavelog cannot update (time, mode,
  /// frequency, station).
  readOnlyFieldsChanged,

  /// Another QSO with the same call, minute, band, mode and station already
  /// exists; Wavelog can store only one of them.
  sameMinuteTwin,
}

/// Sync status of one QSO for one account (the `qso_sync` row).
@immutable
class SyncStatus {
  /// Creates a status.
  const new({
    required this.state,
    this.operation = SyncOperation.create,
    this.remoteQsoId,
    this.attempts = 0,
    this.nextAttemptAt,
    this.problem,
    this.serverMessage,
  });

  /// Where the QSO is.
  final SyncState state;

  /// What the engine has to do next.
  final SyncOperation operation;

  /// Wavelog id once known.
  final int? remoteQsoId;

  /// Failed attempts since the last success.
  final int attempts;

  /// Earliest time (UTC millis) for the next attempt.
  final int? nextAttemptAt;

  /// The last problem, if any.
  final SyncProblem? problem;

  /// The server's message for the last problem (redacted), if any.
  final String? serverMessage;

  /// Whether the worker may pick this QSO at [nowMillis]: queued uploads
  /// and pending verifications whose backoff has elapsed.
  bool isDue(int nowMillis) =>
      (state == SyncState.queued || state == SyncState.verifying) &&
      (nextAttemptAt == null || nextAttemptAt! <= nowMillis);

  SyncStatus _to(
    SyncState state, {
    SyncOperation? operation,
    int? remoteQsoId,
    bool clearRemote = false,
    int? attempts,
    int? nextAttemptAt,
    SyncProblem? problem,
    String? serverMessage,
  }) => SyncStatus(
    state: state,
    operation: operation ?? this.operation,
    remoteQsoId: clearRemote ? null : (remoteQsoId ?? this.remoteQsoId),
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt,
    problem: problem,
    serverMessage: serverMessage,
  );

  @override
  bool operator ==(Object other) =>
      other is SyncStatus &&
      other.state == state &&
      other.operation == operation &&
      other.remoteQsoId == remoteQsoId &&
      other.attempts == attempts &&
      other.nextAttemptAt == nextAttemptAt &&
      other.problem == problem &&
      other.serverMessage == serverMessage;

  @override
  int get hashCode => Object.hash(
    state,
    operation,
    remoteQsoId,
    attempts,
    nextAttemptAt,
    problem,
    serverMessage,
  );

  @override
  String toString() =>
      'SyncStatus(${state.name}, ${operation.name}, remote: $remoteQsoId, '
      'attempts: $attempts, problem: ${problem?.name})';
}

/// Something that happened to a QSO, locally or on the server.
sealed class SyncEvent {
  const new();
}

/// A draft became complete (it has a station location now).
final class QsoCompleted extends SyncEvent {
  /// Creates the event.
  const new();
}

/// The worker started a request for the QSO.
final class RequestStarted extends SyncEvent {
  /// Creates the event.
  const new();
}

/// The server confirmed the operation; for creates, with the new id.
final class RequestSucceeded extends SyncEvent {
  /// Creates the event.
  const new({this.remoteQsoId});

  /// Id assigned by Wavelog (create/replace).
  final int? remoteQsoId;
}

/// The outcome is unknown (timeout, 5xx, app killed), or the server said
/// the QSO already exists: check before retrying.
final class OutcomeUncertain extends SyncEvent {
  /// Creates the event.
  const new(this.problem, {this.serverMessage});

  /// Why the outcome is unknown.
  final SyncProblem problem;

  /// Server text, if any.
  final String? serverMessage;
}

/// A reconcile query found the QSO on the server.
final class ReconcileFound extends SyncEvent {
  /// Creates the event.
  const new(this.remoteQsoId);

  /// The matching server QSO.
  final int remoteQsoId;
}

/// The server QSO matching this one already belongs to another local QSO
/// (same call, minute, band, mode and station): Wavelog can store only one.
final class TwinDetected extends SyncEvent {
  /// Creates the event.
  const new();
}

/// A reconcile query showed the QSO is not on the server.
final class ReconcileNotFound extends SyncEvent {
  /// Creates the event.
  const new();
}

/// Temporary failure before the server processed anything.
final class TransientFailure extends SyncEvent {
  /// Creates the event.
  const new(this.problem, {this.retryAfter});

  /// What went wrong.
  final SyncProblem problem;

  /// Server-requested delay, honoured exactly.
  final Duration? retryAfter;
}

/// The server refused the QSO; the user must fix it.
final class Rejected extends SyncEvent {
  /// Creates the event.
  const new(this.problem, {this.serverMessage});

  /// Why.
  final SyncProblem problem;

  /// Server text, if any.
  final String? serverMessage;
}

/// The token stopped working; the whole account needs the user.
final class AccountBlocked extends SyncEvent {
  /// Creates the event.
  const new(this.problem);

  /// [SyncProblem.tokenInvalid] or [SyncProblem.tokenExpired].
  final SyncProblem problem;
}

/// The user replaced the token.
final class AccountUnblocked extends SyncEvent {
  /// Creates the event.
  const new();
}

/// The user edited the QSO.
final class LocalEdit extends SyncEvent {
  /// Creates the event.
  const new({required this.changesReadOnlyFields});

  /// Whether time, mode, frequency or station changed.
  final bool changesReadOnlyFields;
}

/// The user deleted the QSO.
final class LocalDelete extends SyncEvent {
  /// Creates the event.
  const new({required this.canDeleteOnServer});

  /// Whether the token has `qso:delete`.
  final bool canDeleteOnServer;
}

/// The user resolved a conflict.
final class ConflictResolved extends SyncEvent {
  /// Creates the event.
  const new({required this.replaceOnServer});

  /// true: delete + re-create on the server; false: keep the server
  /// version ("I'll fix it in Wavelog").
  final bool replaceOnServer;
}

/// The app started; requests in flight were interrupted.
final class AppRestarted extends SyncEvent {
  /// Creates the event.
  const new();
}

/// A transition that the state machine does not allow (a bug in the
/// caller, never user error).
class InvalidSyncTransition implements Exception {
  /// Creates the exception.
  const new(this.from, this.event);

  /// State before the event.
  final SyncState from;

  /// The offending event.
  final SyncEvent event;

  @override
  String toString() =>
      'InvalidSyncTransition(${from.name} + ${event.runtimeType})';
}

/// Result of [SyncMachine.apply]: the new status, or null when the QSO
/// needs no sync row anymore (deleted before it ever reached the server).
typedef SyncOutcome = SyncStatus?;

/// The sync state machine. Pure: no I/O, clock and randomness injected.
/// See docs/architecture/sync-state-machine.md.
class SyncMachine {
  /// Creates a machine.
  new({
    this.baseDelay = const Duration(seconds: 30),
    this.maxDelay = const Duration(hours: 6),
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// First retry delay; doubles per attempt.
  final Duration baseDelay;

  /// Upper bound of the retry delay.
  final Duration maxDelay;
  final math.Random _random;

  /// Initial status of a newly logged QSO.
  static SyncStatus initial({required bool complete}) =>
      SyncStatus(state: complete ? SyncState.queued : SyncState.local);

  /// Applies [event] to [status] at [nowMillis].
  SyncOutcome apply(SyncStatus status, SyncEvent event, int nowMillis) {
    final s = status.state;
    Never invalid() => throw InvalidSyncTransition(s, event);

    switch (event) {
      case QsoCompleted():
        if (s == SyncState.local) return status._to(SyncState.queued);
        if (s == SyncState.queued) return status;
        invalid();

      case RequestStarted():
        if (s != SyncState.queued) invalid();
        return status._to(SyncState.uploading, attempts: status.attempts);

      case RequestSucceeded(:final remoteQsoId):
        if (s != SyncState.uploading) invalid();
        if (status.operation == SyncOperation.delete) return null;
        return status._to(
          SyncState.synced,
          operation: SyncOperation.create,
          remoteQsoId: remoteQsoId,
          attempts: 0,
        );

      case OutcomeUncertain(:final problem, :final serverMessage):
        if (s != SyncState.uploading) invalid();
        return status._to(
          SyncState.verifying,
          problem: problem,
          serverMessage: serverMessage,
        );

      case ReconcileFound(:final remoteQsoId):
        if (s != SyncState.verifying) invalid();
        return status._to(
          SyncState.synced,
          operation: SyncOperation.create,
          remoteQsoId: remoteQsoId,
          attempts: 0,
        );

      case TwinDetected():
        if (s != SyncState.verifying && s != SyncState.uploading) invalid();
        return status._to(
          SyncState.conflict,
          clearRemote: true,
          problem: SyncProblem.sameMinuteTwin,
        );

      case ReconcileNotFound():
        if (s != SyncState.verifying) invalid();
        // Confirmed absent: safe to upload again, right away.
        return status._to(
          SyncState.queued,
          attempts: status.attempts + 1,
          problem: status.problem,
        );

      case TransientFailure(:final problem, :final retryAfter):
        if (s != SyncState.uploading && s != SyncState.verifying) invalid();
        // A failed verification stays a verification: never re-upload
        // before the server was checked (ADR 0008).
        return _retryLater(
          status,
          problem,
          retryAfter,
          nowMillis,
          state: s == SyncState.verifying
              ? SyncState.verifying
              : SyncState.queued,
        );

      case Rejected(:final problem, :final serverMessage):
        if (s != SyncState.uploading) invalid();
        return status._to(
          SyncState.rejected,
          attempts: 0,
          problem: problem,
          serverMessage: serverMessage,
        );

      case AccountBlocked(:final problem):
        // Only work that needs the server waits for the user; drafts,
        // conflicts, rejects and synced QSOs keep their state.
        const waiting = {
          SyncState.queued,
          SyncState.uploading,
          SyncState.verifying,
        };
        if (!waiting.contains(s)) return status;
        return status._to(SyncState.blocked, problem: problem);

      case AccountUnblocked():
        if (s != SyncState.blocked) return status;
        // A request may have been in flight when the token failed.
        return status._to(
          status.remoteQsoId == null && status.operation == SyncOperation.create
              ? SyncState.verifying
              : SyncState.queued,
          attempts: 0,
        );

      case LocalEdit(:final changesReadOnlyFields):
        switch (s) {
          case SyncState.local || SyncState.queued:
            return status;
          case SyncState.rejected:
            return status._to(SyncState.queued, attempts: 0);
          case SyncState.synced:
            return changesReadOnlyFields
                ? status._to(
                    SyncState.conflict,
                    problem: SyncProblem.readOnlyFieldsChanged,
                  )
                : status._to(SyncState.queued, operation: SyncOperation.patch);
          case SyncState.conflict:
            // A same-minute twin is resolved by editing (e.g. the time);
            // the edited QSO is a new create.
            return status.problem == SyncProblem.sameMinuteTwin
                ? status._to(SyncState.queued, attempts: 0)
                : status;
          case SyncState.uploading || SyncState.verifying || SyncState.blocked:
            // The engine re-reads the QSO after the current step; an edit
            // during a create is uploaded as a patch afterwards.
            return status;
        }

      case LocalDelete(:final canDeleteOnServer):
        final onServer = status.remoteQsoId != null;
        if (!onServer &&
            (s == SyncState.local ||
                s == SyncState.queued ||
                s == SyncState.rejected ||
                s == SyncState.conflict)) {
          return null; // never reached the server
        }
        if (s == SyncState.uploading || s == SyncState.verifying) {
          // Must learn the outcome first; the engine applies the delete
          // after the step completes.
          return status;
        }
        if (!onServer) return null;
        if (!canDeleteOnServer) {
          // Local-only delete; the journal tells the user the server copy
          // remains.
          return null;
        }
        return status._to(
          SyncState.queued,
          operation: SyncOperation.delete,
          attempts: 0,
        );

      case ConflictResolved(:final replaceOnServer):
        if (s != SyncState.conflict) invalid();
        return replaceOnServer
            ? status._to(
                SyncState.queued,
                operation: SyncOperation.replace,
                attempts: 0,
              )
            : status._to(SyncState.synced, operation: SyncOperation.create);

      case AppRestarted():
        return s == SyncState.uploading
            ? status._to(SyncState.verifying, problem: SyncProblem.network)
            : status;
    }
  }

  SyncStatus _retryLater(
    SyncStatus status,
    SyncProblem problem,
    Duration? retryAfter,
    int nowMillis, {
    SyncState state = SyncState.queued,
  }) {
    final attempts = status.attempts + 1;
    return status._to(
      state,
      attempts: attempts,
      nextAttemptAt:
          nowMillis + (retryAfter ?? backoff(attempts)).inMilliseconds,
      problem: problem,
    );
  }

  /// Delay before retry number [attempts] (1-based): exponential with ±20 %
  /// jitter, capped at [maxDelay].
  Duration backoff(int attempts) {
    final exp = baseDelay.inMilliseconds * math.pow(2, attempts - 1);
    final capped = math.min(exp.toDouble(), maxDelay.inMilliseconds.toDouble());
    final jitter = 0.8 + _random.nextDouble() * 0.4;
    return Duration(milliseconds: (capped * jitter).round());
  }
}
