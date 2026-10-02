import 'package:meta/meta.dart';
import 'package:tideline_data/src/repositories/account_repository.dart';
import 'package:tideline_data/src/repositories/qso_repository.dart';
import 'package:tideline_data/src/repositories/sync_journal_repository.dart';
import 'package:tideline_data/src/repositories/worked_before_repository.dart';
import 'package:tideline_data/src/sync/contest_session_sync.dart';
import 'package:tideline_data/src/sync/wavelog_mapping.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';

/// Builds an API client for [account] with [token]. The app injects one
/// that applies certificate pinning (ADR 0009).
typedef WavelogClientFactory = WavelogClient Function(
  Account account,
  String token,
);

/// How a sync run ended.
enum SyncRunOutcome {
  /// Every due QSO was processed.
  completed,

  /// The server could not be reached; nothing was lost.
  offline,

  /// The token stopped working; the user must act.
  blocked,

  /// The server asked us to slow down; the run stopped early.
  rateLimited,

  /// Another run for this account was already in progress.
  alreadyRunning,
}

/// Summary of one run.
@immutable
class SyncRunResult {
  /// Creates a summary.
  const new(this.outcome, {this.processed = 0});

  /// How it ended.
  final SyncRunOutcome outcome;

  /// QSOs processed.
  final int processed;
}

class _StopRun implements Exception {
  const new(this.outcome);
  final SyncRunOutcome outcome;
}

/// What an upload would do, shown before large uploads.
@immutable
class SyncPreview {
  /// Creates a preview.
  const new({
    required this.toUpload,
    required this.localDuplicates,
    this.serverParsed,
    this.serverReachable = true,
  });

  /// QSOs waiting for their first upload.
  final int toUpload;

  /// Of those, how many look like duplicates of other QSOs in the local log
  /// (same call, minute, band, mode and station). Wavelog keeps only one.
  final int localDuplicates;

  /// How many Wavelog's dry run parsed successfully (null if unknown).
  final int? serverParsed;

  /// Whether the dry run could reach the server.
  final bool serverReachable;
}

/// Uploads, verifies, patches and deletes QSOs for one account at a time.
///
/// Resumable and idempotent: every step is persisted through the
/// [SyncMachine] before and after the request, and an uncertain outcome is
/// always resolved by a reconcile query before any retry (ADR 0008).
class SyncEngine {
  /// Creates the engine.
  new({
    required this.qsos,
    required this.accounts,
    required this.journal,
    required this.machine,
    required this.clientFor,
    this.contestSessions,
    this.workedBefore,
    int Function()? nowMillis,
  }) : _now =
           nowMillis ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  /// QSO and sync-status storage.
  final QsoRepository qsos;

  /// Accounts, tokens, stations.
  final AccountRepository accounts;

  /// The user-visible journal.
  final SyncJournalRepository journal;

  /// The state machine.
  final SyncMachine machine;

  /// Client factory.
  final WavelogClientFactory clientFor;

  /// Mirrors contest sessions on Wavelog 3.2+ (skipped when null).
  final ContestSessionSync? contestSessions;

  /// The worked-before index filled from the server (skipped when null).
  final WorkedBeforeRepository? workedBefore;

  /// Pages of 5,000 QSOs the worked-before pull reads per run at most.
  static const workedBeforePagesPerRun = 10;

  final int Function() _now;
  final Set<String> _running = {};

  /// Call once at app start: requests that were in flight when the app
  /// stopped become verifications.
  Future<void> recoverAfterRestart(String accountId) async {
    for (final (qsoId, status) in await qsos.statuses(accountId)) {
      final next = machine.apply(status, const AppRestarted(), _now());
      if (next != null && next != status) {
        await qsos.writeStatus(qsoId, accountId, next);
      }
    }
  }

  /// Previews an upload of all pending creates without changing anything:
  /// a local duplicate check plus Wavelog's bulk dry run.
  Future<SyncPreview> preview(String accountId) async {
    final pending = await qsos.pendingCreates(accountId);
    final keys = <(String, int, String, String, String?)>{};
    var localDuplicates = 0;
    for (final item in pending) {
      final k = item.qso.dupeKey;
      final key = (
        k.call,
        k.minuteMillis,
        k.band,
        k.mode,
        item.qso.stationProfileId,
      );
      if (!keys.add(key)) localDuplicates++;
    }
    localDuplicates += await qsos.countSyncedMatching(accountId, keys);

    final account = await accounts.find(accountId);
    final token = await accounts.tokenFor(accountId);
    if (account == null || token == null || pending.isEmpty) {
      return SyncPreview(
        toUpload: pending.length,
        localDuplicates: localDuplicates,
        serverReachable: account != null && token != null,
      );
    }
    final client = clientFor(account, token);
    final stations = {
      for (final s in await accounts.watchStations(accountId).first)
        s.id: s.remoteId,
    };
    final byStation = <int, List<Map<String, Object>>>{};
    for (final item in pending) {
      final remote = stations[item.qso.stationProfileId];
      if (remote == null) continue;
      (byStation[remote] ??= []).add(wavelogCreateFields(item.qso));
    }
    try {
      var parsed = 0;
      for (final MapEntry(key: station, value: list) in byStation.entries) {
        parsed += (await client.dryRun(
          stationProfileId: station,
          qsos: list,
        )).parsed;
      }
      return SyncPreview(
        toUpload: pending.length,
        localDuplicates: localDuplicates,
        serverParsed: parsed,
      );
    } on WavelogException {
      return SyncPreview(
        toUpload: pending.length,
        localDuplicates: localDuplicates,
        serverReachable: false,
      );
    }
  }

  /// Runs one sync pass for [accountId].
  Future<SyncRunResult> sync(String accountId) async {
    if (!_running.add(accountId)) {
      return const SyncRunResult(SyncRunOutcome.alreadyRunning);
    }
    try {
      return await _run(accountId);
    } finally {
      _running.remove(accountId);
    }
  }

  Future<SyncRunResult> _run(String accountId) async {
    final account = await accounts.find(accountId);
    if (account == null) {
      return const SyncRunResult(SyncRunOutcome.completed);
    }
    final token = await accounts.tokenFor(accountId);
    if (token == null) {
      await _blockAccount(accountId, SyncProblem.tokenInvalid);
      return const SyncRunResult(SyncRunOutcome.blocked);
    }
    final client = clientFor(account, token);
    await journal.append(
      accountId: accountId,
      event: JournalEvent.runStarted,
      at: _now(),
    );

    var processed = 0;
    try {
      await _refreshAccount(account, client);
      await _unblock(accountId);
      final stations = {
        for (final s in await accounts.watchStations(accountId).first)
          s.id: s.remoteId,
      };
      for (final item in await qsos.due(accountId, _now())) {
        await _process(account, client, item, stations);
        processed++;
      }
      // Scopes and capabilities may have changed in _refreshAccount.
      final refreshed = await accounts.find(accountId) ?? account;
      await _syncContestSessions(refreshed, client, stations);
      await _pullWorkedBefore(refreshed, client);
      return SyncRunResult(SyncRunOutcome.completed, processed: processed);
    } on _StopRun catch (stop) {
      return SyncRunResult(stop.outcome, processed: processed);
    } finally {
      await journal.append(
        accountId: accountId,
        event: JournalEvent.runFinished,
        at: _now(),
        detail: {'processed': processed},
      );
    }
  }

  Future<void> _refreshAccount(Account account, WavelogClient client) async {
    try {
      final token = await client.tokenInfo();
      final stations = await client.stations();
      await accounts.updateCapabilities(
        account.id,
        usesIndexPhp: account.usesIndexPhp,
        scopes: token.scopes,
        hasContestSessions: account.hasContestSessions,
        tokenExpiresAt: token.expiresAt?.millisecondsSinceEpoch,
      );
      await accounts.syncStations(account.id, [
        for (final s in stations)
          (
            remoteId: s.id,
            name: s.name,
            callsign: s.callsign,
            grid: s.gridsquare,
            active: s.active,
          ),
      ], nowMillis: _now());
    } on WavelogUnauthorized catch (e) {
      await _blockAccount(
        account.id,
        e.isExpired ? SyncProblem.tokenExpired : SyncProblem.tokenInvalid,
      );
      throw const _StopRun(SyncRunOutcome.blocked);
    } on WavelogNetworkError {
      throw const _StopRun(SyncRunOutcome.offline);
    } on WavelogRateLimited {
      throw const _StopRun(SyncRunOutcome.rateLimited);
    } on WavelogException {
      // Server trouble (5xx, malformed): try again next run.
      throw const _StopRun(SyncRunOutcome.offline);
    }
  }

  Future<void> _syncContestSessions(
    Account account,
    WavelogClient client,
    Map<String, int> stations,
  ) async {
    final step = contestSessions;
    if (step == null || !account.scopes.contains('contest:write')) return;
    try {
      await step.run(account, client, stations);
    } on WavelogUnauthorized catch (e) {
      await _blockAccount(
        account.id,
        e.isExpired ? SyncProblem.tokenExpired : SyncProblem.tokenInvalid,
      );
      throw const _StopRun(SyncRunOutcome.blocked);
    } on WavelogNetworkError {
      throw const _StopRun(SyncRunOutcome.offline);
    } on WavelogRateLimited {
      throw const _StopRun(SyncRunOutcome.rateLimited);
    }
  }

  /// Pulls new server QSOs into the worked-before index. Best effort: any
  /// failure just ends the pull until the next run.
  Future<void> _pullWorkedBefore(Account account, WavelogClient client) async {
    final index = workedBefore;
    if (index == null || !account.scopes.contains('qso:read')) return;
    try {
      var cursor = await index.lastFetchedId(account.id);
      for (var page = 0; page < workedBeforePagesPerRun; page++) {
        final result = await client.fetchQsosAdif(sinceId: cursor);
        if (result.adif.isNotEmpty) {
          await index.mergeServerAdif(account.id, result.adif);
        }
        if (result.lastFetchedId == cursor) break;
        cursor = result.lastFetchedId;
        await index.setLastFetchedId(account.id, cursor);
        if (!result.hasMore) break;
      }
    } on WavelogException {
      return;
    }
  }

  Future<void> _process(
    Account account,
    WavelogClient client,
    LoggedQso item,
    Map<String, int> stations,
  ) async {
    final status = item.status!;
    if (status.state == SyncState.verifying) {
      final confirmedAbsent = await _reconcile(account, client, item, stations);
      if (confirmedAbsent) {
        // Safe to upload now; a failure here waits for the next run, so a
        // persistently failing server cannot loop.
        final queued = await qsos.readStatus(item.qso.id, item.qso.accountId);
        if (queued != null && queued.state == SyncState.queued) {
          await _process(
            account,
            client,
            LoggedQso(item.qso, queued),
            stations,
          );
        }
      }
      return;
    }
    switch (status.operation) {
      case SyncOperation.create:
        await _create(account, client, item, stations);
      case SyncOperation.replace:
        await _replace(account, client, item, stations);
      case SyncOperation.patch:
        await _idempotent(account, item, () async {
          await client.patchQso(
            status.remoteQsoId!,
            wavelogPatchFields(item.qso),
          );
          return JournalEvent.patched;
        });
      case SyncOperation.delete:
        await _idempotent(account, item, () async {
          await client.deleteQso(status.remoteQsoId!);
          return JournalEvent.deletedOnServer;
        });
    }
  }

  Future<void> _create(
    Account account,
    WavelogClient client,
    LoggedQso item,
    Map<String, int> stations,
  ) async {
    final qso = item.qso;
    final remoteStation = stations[qso.stationProfileId];
    final started = await _apply(item, const RequestStarted());
    if (remoteStation == null) {
      await _apply(
        item,
        const Rejected(SyncProblem.stationNotAllowed),
        from: started,
      );
      await _log(account, qso, JournalEvent.rejected, {
        'problem': SyncProblem.stationNotAllowed.name,
      });
      return;
    }
    await _log(account, qso, JournalEvent.requestStarted, {
      'operation': 'create',
    });
    try {
      final id = await client.createQso(
        stationProfileId: remoteStation,
        fields: wavelogCreateFields(qso),
      );
      await _apply(item, RequestSucceeded(remoteQsoId: id), from: started);
      await _log(account, qso, JournalEvent.uploaded, {'remoteId': id});
    } on WavelogValidationError catch (e) {
      if (e.isDuplicate) {
        final verifying = await _apply(
          item,
          OutcomeUncertain(
            SyncProblem.invalidData,
            serverMessage: e.serverMessage,
          ),
          from: started,
        );
        await _reconcile(account, client, LoggedQso(qso, verifying), stations);
        return;
      }
      await _reject(account, item, started, SyncProblem.invalidData, e);
    } on WavelogForbidden catch (e) {
      await _reject(
        account,
        item,
        started,
        e.isInsufficientScope
            ? SyncProblem.missingPermission
            : SyncProblem.stationNotAllowed,
        e,
      );
    } on WavelogException catch (e) {
      await _handleFailure(account, item, started, e, uncertain: true);
      // An uncertain create is checked right away when the server is up.
      final now = await qsos.readStatus(qso.id, qso.accountId);
      if (now?.state == SyncState.verifying &&
          e is! WavelogNetworkError &&
          e is! WavelogRateLimited) {
        await _reconcile(account, client, LoggedQso(qso, now), stations);
      }
    }
  }

  Future<void> _replace(
    Account account,
    WavelogClient client,
    LoggedQso item,
    Map<String, int> stations,
  ) async {
    final status = item.status!;
    final remote = status.remoteQsoId;
    if (remote != null) {
      try {
        await client.deleteQso(remote);
      } on WavelogException catch (e) {
        final started = await _apply(item, const RequestStarted());
        await _handleFailure(account, item, started, e, uncertain: false);
        return;
      }
      // The old server copy is gone; from now on this is a plain create.
      final asCreate = SyncStatus(
        state: SyncState.queued,
        attempts: status.attempts,
      );
      await qsos.writeStatus(item.qso.id, item.qso.accountId, asCreate);
      await _create(account, client, LoggedQso(item.qso, asCreate), stations);
      return;
    }
    await _create(account, client, item, stations);
  }

  /// Checks the server for [item]. Returns true when it is confirmed
  /// absent (and now queued for upload).
  Future<bool> _reconcile(
    Account account,
    WavelogClient client,
    LoggedQso item,
    Map<String, int> stations,
  ) async {
    final qso = item.qso;
    final remoteStation = stations[qso.stationProfileId];
    try {
      final day = qso.timeOn.value;
      final candidates = await client.findQsos(
        callsign: qso.call.value,
        since: day,
        until: day,
        stationId: remoteStation,
      );
      final key = qso.dupeKey;
      final match = candidates.where(
        (c) =>
            c.call == key.call &&
            c.band == key.band &&
            c.mode == key.mode &&
            UtcDateTime(c.time).toMinute.millis == key.minuteMillis &&
            (remoteStation == null || c.stationId == remoteStation),
      );
      if (match.isEmpty) {
        await _apply(item, const ReconcileNotFound());
        await _log(account, qso, JournalEvent.notOnServer, const {});
        return true;
      }
      final remoteId = match.first.id;
      final owner = await qsos.ownerOfRemote(account.id, remoteId);
      if (owner != null && owner != qso.id) {
        await _apply(item, const TwinDetected());
        await _log(account, qso, JournalEvent.conflict, {
          'problem': SyncProblem.sameMinuteTwin.name,
          'twin': owner,
        });
        return false;
      }
      await _apply(item, ReconcileFound(remoteId));
      await _log(account, qso, JournalEvent.verifiedOnServer, {
        'remoteId': remoteId,
      });
      return false;
    } on WavelogException catch (e) {
      await _handleFailure(account, item, item.status!, e, uncertain: false);
      return false;
    }
  }

  /// Patch and delete are idempotent: failures are simply retried.
  Future<void> _idempotent(
    Account account,
    LoggedQso item,
    Future<JournalEvent> Function() request,
  ) async {
    final started = await _apply(item, const RequestStarted());
    try {
      final event = await request();
      final next = machine.apply(started, const RequestSucceeded(), _now());
      if (next == null) {
        await qsos.clearStatus(item.qso.id, item.qso.accountId);
      } else {
        await qsos.writeStatus(item.qso.id, item.qso.accountId, next);
      }
      await _log(account, item.qso, event, {'remoteId': started.remoteQsoId});
    } on WavelogNotFound catch (e) {
      await _reject(account, item, started, SyncProblem.invalidData, e);
    } on WavelogValidationError catch (e) {
      await _reject(account, item, started, SyncProblem.invalidData, e);
    } on WavelogForbidden catch (e) {
      await _reject(account, item, started, SyncProblem.missingPermission, e);
    } on WavelogException catch (e) {
      await _handleFailure(account, item, started, e, uncertain: false);
    }
  }

  Future<void> _handleFailure(
    Account account,
    LoggedQso item,
    SyncStatus current,
    WavelogException e, {
    required bool uncertain,
  }) async {
    switch (e) {
      case WavelogUnauthorized():
        await _blockAccount(
          account.id,
          e.isExpired ? SyncProblem.tokenExpired : SyncProblem.tokenInvalid,
        );
        throw const _StopRun(SyncRunOutcome.blocked);
      case WavelogRateLimited(:final retryAfter):
        await _apply(
          item,
          TransientFailure(SyncProblem.rateLimited, retryAfter: retryAfter),
          from: current,
        );
        await _log(account, item.qso, JournalEvent.retryScheduled, {
          'problem': SyncProblem.rateLimited.name,
          'retryAfterSeconds': retryAfter.inSeconds,
        });
        throw const _StopRun(SyncRunOutcome.rateLimited);
      case WavelogNetworkError():
        await _apply(
          item,
          uncertain
              ? const OutcomeUncertain(SyncProblem.network)
              : const TransientFailure(SyncProblem.network),
          from: current,
        );
        throw const _StopRun(SyncRunOutcome.offline);
      default:
        await _apply(
          item,
          uncertain
              ? OutcomeUncertain(
                  SyncProblem.serverError,
                  serverMessage: e.serverMessage,
                )
              : const TransientFailure(SyncProblem.serverError),
          from: current,
        );
        await _log(account, item.qso, JournalEvent.retryScheduled, {
          'problem': SyncProblem.serverError.name,
          'server': e.serverMessage,
        });
    }
  }

  Future<void> _reject(
    Account account,
    LoggedQso item,
    SyncStatus current,
    SyncProblem problem,
    WavelogException e,
  ) async {
    await _apply(
      item,
      Rejected(problem, serverMessage: e.serverMessage),
      from: current,
    );
    await _log(account, item.qso, JournalEvent.rejected, {
      'problem': problem.name,
      'code': e.code,
      'server': e.serverMessage,
    });
  }

  Future<void> _blockAccount(String accountId, SyncProblem problem) async {
    for (final (qsoId, status) in await qsos.statuses(accountId)) {
      final next = machine.apply(status, AccountBlocked(problem), _now());
      if (next != null && next != status) {
        await qsos.writeStatus(qsoId, accountId, next);
      }
    }
    await journal.append(
      accountId: accountId,
      event: JournalEvent.accountBlocked,
      at: _now(),
      detail: {'problem': problem.name},
    );
  }

  Future<void> _unblock(String accountId) async {
    for (final (qsoId, status) in await qsos.statuses(accountId)) {
      if (status.state != SyncState.blocked) continue;
      final next = machine.apply(status, const AccountUnblocked(), _now());
      if (next != null) await qsos.writeStatus(qsoId, accountId, next);
    }
  }

  Future<SyncStatus> _apply(
    LoggedQso item,
    SyncEvent event, {
    SyncStatus? from,
  }) async {
    final current =
        from ?? await qsos.readStatus(item.qso.id, item.qso.accountId);
    final next = machine.apply(current!, event, _now());
    if (next == null) {
      await qsos.clearStatus(item.qso.id, item.qso.accountId);
      return current;
    }
    await qsos.writeStatus(item.qso.id, item.qso.accountId, next);
    return next;
  }

  Future<void> _log(
    Account account,
    Qso qso,
    JournalEvent event,
    Map<String, Object?> detail,
  ) => journal.append(
    accountId: account.id,
    qsoId: qso.id,
    event: event,
    at: _now(),
    detail: {'call': qso.call.value, ...detail},
  );
}
