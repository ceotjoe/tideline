import 'package:drift/drift.dart' show Value;
import 'package:tideline_data/src/repositories/account_repository.dart';
import 'package:tideline_data/src/repositories/contest_definition_repository.dart';
import 'package:tideline_data/src/repositories/contest_session_repository.dart';
import 'package:tideline_data/src/repositories/sync_journal_repository.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';

/// Why a contest session is not (yet) mirrored on Wavelog. Stored in
/// `contest_sessions.remote_error_key`; the app localises it.
abstract final class ContestSyncProblem {
  /// The contest is unknown or not activated by the Wavelog admin.
  static const contestNotActive = 'contestNotActive';

  /// The token lacks `contest:write`.
  static const missingPermission = 'contestMissingPermission';

  /// The server has no contest sessions (older than 3.2).
  static const serverTooOld = 'contestServerTooOld';

  /// The session was deleted in Wavelog.
  static const deletedOnServer = 'contestDeletedOnServer';

  /// The definition has no ADIF contest name.
  static const noAdifName = 'contestNoAdifName';

  /// The session's station location is not (or no longer) on the server.
  static const stationUnknown = 'contestStationUnknown';

  /// The server rejected the request for another reason.
  static const rejected = 'contestRejected';
}

/// Mirrors local contest sessions as Wavelog 3.2+ contest sessions and links
/// their uploaded QSOs (see `docs/architecture/sync-state-machine.md`).
///
/// Network, rate-limit and token errors propagate, so the sync engine can
/// stop the run; the persisted `verifying` state makes a retried create
/// safe. Other server errors are journaled and retried next run.
class ContestSessionSync {
  /// Creates the step.
  new({
    required this.sessions,
    required this.definitions,
    required this.journal,
    int Function()? nowMillis,
  }) : _now =
           nowMillis ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  /// Contest sessions and their links.
  final ContestSessionRepository sessions;

  /// Contest definitions (for the ADIF name and exchange).
  final ContestDefinitionRepository definitions;

  /// The user-visible journal.
  final SyncJournalRepository journal;

  final int Function() _now;

  /// Wavelog requires `time_end > time_start`.
  static const _minimumLength = Duration(minutes: 1);

  /// Runs the step for every mirrored session of [account]. [stations] maps
  /// local station profile ids to Wavelog station ids.
  Future<void> run(
    Account account,
    WavelogClient client,
    Map<String, int> stations,
  ) async {
    if (!account.hasContestSessions) return;
    for (final session in await sessions.needingRemoteSync(account.id)) {
      try {
        await _syncOne(account, client, session, stations);
      } on WavelogNetworkError {
        rethrow;
      } on WavelogRateLimited {
        rethrow;
      } on WavelogUnauthorized {
        rethrow;
      } on WavelogException catch (e) {
        // 5xx or a malformed answer: try again next run.
        await _log(account, session, JournalEvent.contestSessionRetry, {
          'code': e.code,
          'server': e.serverMessage,
        });
      }
    }
  }

  Future<void> _syncOne(
    Account account,
    WavelogClient client,
    ContestSession session,
    Map<String, int> stations,
  ) async {
    final definition = await definitions.find(session.definitionId);
    final adif = definition?.adif;
    if (definition == null || adif == null) {
      await _localOnly(account, session, ContestSyncProblem.noAdifName);
      return;
    }
    final station = stations[session.stationProfileId];
    if (station == null) {
      await _problem(account, session, ContestSyncProblem.stationUnknown);
      return;
    }

    var current = session;
    if (current.remoteState == ContestRemoteState.verifying) {
      current = await _reconcile(account, client, current, adif, station);
    }
    switch (current.remoteState) {
      case ContestRemoteState.pending:
        await _create(account, client, current, definition, adif, station);
      case ContestRemoteState.created:
        await _update(account, client, current);
      case ContestRemoteState.local:
      case ContestRemoteState.verifying:
        break;
    }
  }

  /// Looks for a session a lost create request may have made: same contest
  /// and station, same start minute. Returns the session in its new state.
  Future<ContestSession> _reconcile(
    Account account,
    WavelogClient client,
    ContestSession session,
    String adif,
    int station,
  ) async {
    final startMinute = UtcDateTime.fromMillis(session.startedAt).toMinute;
    final match = (await client.listContestSessions(stationId: station))
        .where(
          (r) =>
              r.contestAdifName == adif &&
              r.stationId == station &&
              UtcDateTime(r.start).toMinute == startMinute,
        )
        .firstOrNull;
    if (match == null) {
      await sessions.setRemote(session.id, state: ContestRemoteState.pending);
    } else {
      await sessions.setRemote(
        session.id,
        state: ContestRemoteState.created,
        remoteSessionId: Value(match.id),
        remoteEndSynced: Value(match.end.millisecondsSinceEpoch),
        errorKey: const Value(null),
      );
      await _log(account, session, JournalEvent.contestSessionCreated, {
        'remoteSessionId': match.id,
        'reconciled': true,
      });
    }
    return (await sessions.find(session.id))!;
  }

  Future<void> _create(
    Account account,
    WavelogClient client,
    ContestSession session,
    ContestDefinition definition,
    String adif,
    int station,
  ) async {
    final remoteIds = await sessions.remoteQsoIds(session.id);
    // Nothing to show on the server until a QSO of the session is there.
    if (remoteIds.isEmpty) return;
    final end = await _endFor(session);
    // Persisted before the request, so a lost answer is reconciled.
    await sessions.setRemote(session.id, state: ContestRemoteState.verifying);
    final WavelogContestSession created;
    try {
      created = await client.createContestSession(
        contestAdifName: adif,
        start: _utc(session.startedAt),
        end: _utc(end),
        stationId: station,
        settings: {'exchangefields': exchangeFieldsFor(definition)},
        qsoIds: remoteIds.values.toList(),
      );
    } on WavelogValidationError catch (e) {
      await sessions.setRemote(session.id, state: ContestRemoteState.pending);
      if (e.isContestRejected) {
        await _localOnly(account, session, ContestSyncProblem.contestNotActive);
      } else {
        await _problem(account, session, ContestSyncProblem.rejected, e);
      }
      return;
    } on WavelogForbidden catch (e) {
      await sessions.setRemote(session.id, state: ContestRemoteState.pending);
      await _problem(
        account,
        session,
        e.isInsufficientScope
            ? ContestSyncProblem.missingPermission
            : ContestSyncProblem.stationUnknown,
        e,
      );
      return;
    } on WavelogNotFound {
      await _localOnly(account, session, ContestSyncProblem.serverTooOld);
      return;
    }
    await sessions.setRemote(
      session.id,
      state: ContestRemoteState.created,
      remoteSessionId: Value(created.id),
      remoteEndSynced: Value(end),
      errorKey: const Value(null),
    );
    await sessions.recordLinks(session.id, remoteIds);
    await _log(account, session, JournalEvent.contestSessionCreated, {
      'remoteSessionId': created.id,
      'linked': remoteIds.length,
      'skipped': created.skippedQsoIds?.length ?? 0,
    });
  }

  /// Links newly uploaded QSOs and moves the end time.
  Future<void> _update(
    Account account,
    WavelogClient client,
    ContestSession session,
  ) async {
    final remoteSession = session.remoteSessionId;
    if (remoteSession == null) {
      // Cannot happen through this class; recover by creating again.
      await sessions.setRemote(session.id, state: ContestRemoteState.pending);
      return;
    }
    final linked = await sessions.linkedQsos(session.id);
    final toLink = {
      for (final MapEntry(:key, :value) in (await sessions.remoteQsoIds(
        session.id,
      )).entries)
        if (!linked.containsKey(key)) key: value,
    };
    final end = await _endFor(session);
    final endChanged = end != session.remoteEndSynced;
    if (toLink.isEmpty && !endChanged) return;
    final WavelogContestSession patched;
    try {
      patched = await client.patchContestSession(
        remoteSession,
        linkQsoIds: toLink.values.toList(),
        end: endChanged ? _utc(end) : null,
      );
    } on WavelogNotFound {
      await _localOnly(account, session, ContestSyncProblem.deletedOnServer);
      return;
    } on WavelogForbidden catch (e) {
      await _problem(account, session, ContestSyncProblem.missingPermission, e);
      return;
    } on WavelogValidationError catch (e) {
      await _problem(account, session, ContestSyncProblem.rejected, e);
      return;
    }
    // QSOs the server skipped (already in another session) are recorded
    // too, so they are not retried on every run; the journal names them.
    if (toLink.isNotEmpty) {
      await sessions.recordLinks(session.id, toLink);
      await _log(account, session, JournalEvent.contestQsosLinked, {
        'linked': toLink.length,
        'skipped': patched.skippedQsoIds?.length ?? 0,
      });
    }
    await sessions.setRemote(
      session.id,
      remoteEndSynced: Value(end),
      errorKey: const Value(null),
    );
  }

  /// The end time sent to Wavelog: the session end, else its latest QSO,
  /// and always at least one minute after the start.
  Future<int> _endFor(ContestSession session) async {
    final end =
        session.endedAt ??
        await sessions.latestQsoTime(session.id) ??
        session.startedAt;
    final minimum = session.startedAt + _minimumLength.inMilliseconds;
    return end < minimum ? minimum : end;
  }

  /// Wavelog's `settings.exchangefields` for [definition]: what the received
  /// exchange contains, over all variants.
  static List<String> exchangeFieldsFor(ContestDefinition definition) {
    final kinds = {
      for (final e in definition.exchange.rcvd) e.kind,
      for (final v in definition.exchange.variants)
        for (final e in v.rcvd ?? const <ExchangeElement>[]) e.kind,
    };
    return [
      if (kinds.contains(ExchangeKind.serial)) 'serial',
      if (kinds.contains(ExchangeKind.grid)) 'gridsquare',
      if (kinds.any(
        (k) =>
            k != ExchangeKind.rst &&
            k != ExchangeKind.serial &&
            k != ExchangeKind.grid,
      ))
        'exchange',
    ];
  }

  Future<void> _localOnly(
    Account account,
    ContestSession session,
    String problem,
  ) async {
    await sessions.setRemote(
      session.id,
      state: ContestRemoteState.local,
      errorKey: Value(problem),
    );
    await _log(account, session, JournalEvent.contestSessionLocalOnly, {
      'problem': problem,
    });
  }

  /// Records a problem that is retried next run. The journal gets an entry
  /// only when the problem changes, so a long-standing one does not flood
  /// it.
  Future<void> _problem(
    Account account,
    ContestSession session,
    String problem, [
    WavelogException? e,
  ]) async {
    if (session.remoteErrorKey == problem) return;
    await sessions.setRemote(session.id, errorKey: Value(problem));
    await _log(account, session, JournalEvent.contestSessionRetry, {
      'problem': problem,
      'code': ?e?.code,
      'server': ?e?.serverMessage,
    });
  }

  DateTime _utc(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);

  Future<void> _log(
    Account account,
    ContestSession session,
    JournalEvent event,
    Map<String, Object?> detail,
  ) => journal.append(
    accountId: account.id,
    event: event,
    at: _now(),
    detail: {'session': session.id, ...detail},
  );
}
