import 'dart:convert';

import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_data/src/repositories/account_repository.dart';
import 'package:tideline_data/src/repositories/qso_repository.dart';
import 'package:tideline_data/src/sync/qso_eviction_service.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';

/// What [QsoRefreshService.refresh] did.
enum RefreshOutcome {
  /// The local copy now matches Wavelog.
  refreshed,

  /// Wavelog has no QSO under this id anymore (deleted there). Nothing
  /// changed.
  goneOnServer,

  /// Wavelog's record could not be read as a QSO. Nothing changed.
  unreadable,

  /// The QSO is not eligible (not synced, in a contest or activation) or it
  /// was edited here while the server was asked. Nothing changed.
  notEligible,
}

/// Brings one synced QSO back in line with the version Wavelog has, for a QSO
/// that was changed in Wavelog itself (ADR 0035).
///
/// Read-only towards the server: one `GET /qso?format=adif` for exactly that
/// id. Contest and activation QSOs are left alone.
class QsoRefreshService {
  /// Creates the service.
  new({required this.qsos, required this.accounts, required this.clientFor});

  /// The log.
  final QsoRepository qsos;

  /// Accounts and their tokens.
  final AccountRepository accounts;

  /// Builds the API client of an account.
  final WavelogClient Function(Account account, String token) clientFor;

  /// Replaces the local copy of [qsoId] with Wavelog's. Throws
  /// [EvictionCheckFailed] if Wavelog cannot be asked (the problems are the
  /// same as for removing QSOs from the device).
  Future<RefreshOutcome> refresh(Account account, String qsoId) async {
    final local = await qsos.find(qsoId);
    final status = local?.status;
    final remoteId = status?.remoteQsoId;
    if (local == null ||
        local.qso.accountId != account.id ||
        status == null ||
        status.state != SyncState.synced ||
        remoteId == null ||
        local.qso.contestSessionId != null ||
        local.qso.activationId != null) {
      return RefreshOutcome.notEligible;
    }
    final rev = await qsos.revOf(qsoId);
    if (rev == null) return RefreshOutcome.notEligible;
    final token = await accounts.tokenFor(account.id);
    if (token == null) {
      throw const EvictionCheckFailed(EvictionCheckProblem.unauthorized);
    }
    final WavelogAdifPage page;
    try {
      // Ascending ids above `remoteId - 1`: the first one is the QSO itself,
      // or a later one when it is gone.
      page = await clientFor(
        account,
        token,
      ).fetchQsosAdif(sinceId: remoteId - 1, perPage: 1);
    } on WavelogUnauthorized {
      throw const EvictionCheckFailed(EvictionCheckProblem.unauthorized);
    } on WavelogForbidden {
      throw const EvictionCheckFailed(EvictionCheckProblem.unauthorized);
    } on WavelogNetworkError {
      throw const EvictionCheckFailed(EvictionCheckProblem.offline);
    } on WavelogException {
      throw const EvictionCheckFailed(EvictionCheckProblem.server);
    }
    if (page.exported < 1 || page.lastFetchedId != remoteId) {
      return RefreshOutcome.goneOnServer;
    }
    final records = const AdiParser().parse(utf8.encode(page.adif)).records;
    if (records.length != 1) return RefreshOutcome.unreadable;
    final result = AdifQsoMapping.fromRecord(
      records.single,
      id: local.qso.id,
      accountId: local.qso.accountId,
      stationProfileId: local.qso.stationProfileId,
    );
    if (result is! AdifImported) return RefreshOutcome.unreadable;
    final applied = await qsos.applyServerVersion(result.qso, expectedRev: rev);
    return applied ? RefreshOutcome.refreshed : RefreshOutcome.notEligible;
  }
}
