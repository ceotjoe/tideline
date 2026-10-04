import 'dart:async';

import 'package:meta/meta.dart';
import 'package:tideline_data/src/repositories/account_repository.dart';
import 'package:tideline_data/src/repositories/qso_eviction_repository.dart';
import 'package:tideline_data/src/repositories/qso_repository.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';

/// Why the check against Wavelog could not be made. Nothing is removed then.
enum EvictionCheckProblem {
  /// No answer from the server.
  offline,

  /// The token is missing, revoked or expired.
  unauthorized,

  /// The server failed or answered with something unexpected.
  server,

  /// The list of QSOs in the range is larger than a check can read.
  tooMany,
}

/// The check against Wavelog could not be made.
class EvictionCheckFailed implements Exception {
  /// Creates the exception.
  const new(this.problem);

  /// What went wrong.
  final EvictionCheckProblem problem;

  @override
  String toString() => 'EvictionCheckFailed(${problem.name})';
}

/// What would be removed, after asking Wavelog.
@immutable
class EvictionPlan {
  /// Creates a plan.
  const new({
    required this.accountId,
    required this.confirmed,
    required this.missingOnServer,
    required this.blocked,
  });

  /// The account.
  final String accountId;

  /// QSOs the server has, with the same call, minute, band and mode.
  final List<LoggedQso> confirmed;

  /// QSOs that look synced here but were not found on the server (deleted or
  /// changed there). They stay.
  final List<LoggedQso> missingOnServer;

  /// QSOs of the scope that stay for local reasons.
  final Map<EvictionBlock, int> blocked;
}

/// Plans and carries out the removal of local copies of QSOs that Wavelog has.
///
/// The plan asks the server (one date-range listing, read-only) and only
/// QSOs it finds with the same duplicate key are confirmed; without an answer
/// nothing is removed. See ADR 0027.
class QsoEvictionService {
  /// Creates the service.
  new({
    required this.eviction,
    required this.accounts,
    required this.clientFor,
  });

  /// Local eligibility and the removal itself.
  final QsoEvictionRepository eviction;

  /// Accounts and their tokens.
  final AccountRepository accounts;

  /// Builds the API client of an account.
  final WavelogClient Function(Account account, String token) clientFor;

  /// The QSOs of [account] in a scope (see
  /// [QsoEvictionRepository.candidates]) that are eligible locally and that
  /// Wavelog confirms. Throws [EvictionCheckFailed] if Wavelog cannot be
  /// asked.
  Future<EvictionPlan> plan(
    Account account, {
    int? olderThanMillis,
    Set<String>? ids,
  }) async {
    final local = await eviction.candidates(
      account.id,
      olderThanMillis: olderThanMillis,
      ids: ids,
    );
    if (local.eligible.isEmpty) {
      return EvictionPlan(
        accountId: account.id,
        confirmed: const [],
        missingOnServer: const [],
        blocked: local.blocked,
      );
    }
    final token = await accounts.tokenFor(account.id);
    if (token == null) {
      throw const EvictionCheckFailed(EvictionCheckProblem.unauthorized);
    }
    final client = clientFor(account, token);
    final times = [for (final i in local.eligible) i.qso.timeOn.value];
    final since = times.reduce((a, b) => a.isBefore(b) ? a : b);
    final until = times.reduce((a, b) => a.isAfter(b) ? a : b);
    final List<WavelogQso> remote;
    try {
      // A day either side: the server's date is UTC, like ours, but the
      // listing is by day.
      remote = await client.findQsos(
        since: since.subtract(const Duration(days: 1)),
        until: until.add(const Duration(days: 1)),
        maxPages: 200,
        perPage: 5000,
      );
    } on WavelogUnauthorized {
      throw const EvictionCheckFailed(EvictionCheckProblem.unauthorized);
    } on WavelogForbidden {
      throw const EvictionCheckFailed(EvictionCheckProblem.unauthorized);
    } on WavelogNetworkError {
      throw const EvictionCheckFailed(EvictionCheckProblem.offline);
    } on WavelogMalformedResponse catch (e) {
      throw EvictionCheckFailed(
        '$e'.contains('too many pages')
            ? EvictionCheckProblem.tooMany
            : EvictionCheckProblem.server,
      );
    } on WavelogException {
      throw const EvictionCheckFailed(EvictionCheckProblem.server);
    }
    final byId = {for (final q in remote) q.id: q};
    final stations = await eviction.stationRemoteIds(account.id);

    final confirmed = <LoggedQso>[];
    final missing = <LoggedQso>[];
    for (final item in local.eligible) {
      final qso = item.qso;
      final key = qso.dupeKey;
      final server = byId[item.status!.remoteQsoId];
      final remoteStation = stations[qso.stationProfileId];
      final same =
          server != null &&
          server.call == key.call &&
          server.band == key.band &&
          server.mode == key.mode &&
          UtcDateTime(server.time).toMinute.millis == key.minuteMillis &&
          (remoteStation == null || server.stationId == remoteStation);
      (same ? confirmed : missing).add(item);
    }
    return EvictionPlan(
      accountId: account.id,
      confirmed: confirmed,
      missingOnServer: missing,
      blocked: local.blocked,
    );
  }

  /// Removes the local copies of [plan]'s confirmed QSOs. Returns how many
  /// were removed (fewer if one changed since the plan was made).
  Future<int> carryOut(EvictionPlan plan) => eviction.evict(plan.accountId, [
    for (final i in plan.confirmed) i.qso.id,
  ]);
}
