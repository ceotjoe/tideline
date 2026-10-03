import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A configured Wavelog account. The token is never part of this object.
@immutable
class Account {
  /// Creates an account view.
  const new({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.usesIndexPhp,
    required this.allowHttpLan,
    required this.scopes,
    required this.hasContestSessions,
    this.certPinSha256,
    this.tokenExpiresAt,
  });

  /// Local UUID.
  final String id;

  /// User-chosen name.
  final String label;

  /// Installation base URL (without `index.php`).
  final String baseUrl;

  /// Whether API URLs need `index.php/`.
  final bool usesIndexPhp;

  /// Plain-HTTP opt-in for a private-LAN server.
  final bool allowHttpLan;

  /// TOFU-pinned leaf certificate fingerprint (SHA-256 hex), if any.
  final String? certPinSha256;

  /// Granted token scopes.
  final Set<String> scopes;

  /// Wavelog 3.2+ contest sessions available.
  final bool hasContestSessions;

  /// Token expiry (UTC millis), if any.
  final int? tokenExpiresAt;

  /// Whether the token may delete QSOs on the server.
  bool get canDeleteOnServer => scopes.contains('qso:delete');
}

/// A cached Wavelog station location.
@immutable
class StationProfile {
  /// Creates a station profile view.
  const new({
    required this.id,
    required this.accountId,
    required this.remoteId,
    required this.name,
    required this.callsign,
    required this.active,
    this.gridsquare,
    this.references = const StationReferences(),
  });

  /// Local UUID.
  final String id;

  /// Owning account.
  final String accountId;

  /// Wavelog `station_profile_id`.
  final int remoteId;

  /// Display name.
  final String name;

  /// Station callsign.
  final String callsign;

  /// Locator.
  final String? gridsquare;

  /// Active location in Wavelog.
  final bool active;

  /// The programme references stored on the location in Wavelog.
  final StationReferences references;
}

/// The SOTA, POTA, WWFF, IOTA and SIG values of a Wavelog station location.
///
/// Wavelog files every uploaded QSO under such a location and copies these
/// values into the QSO's own `MY_*` fields, ignoring what the upload says
/// (docs/architecture/wavelog-api.md, "Own references").
@immutable
class StationReferences {
  /// Creates the values; all are optional.
  const new({
    this.sota,
    this.pota,
    this.wwff,
    this.iota,
    this.sig,
    this.sigInfo,
  });

  /// SOTA reference.
  final String? sota;

  /// POTA reference.
  final String? pota;

  /// WWFF reference.
  final String? wwff;

  /// IOTA reference.
  final String? iota;

  /// Special interest group.
  final String? sig;

  /// Special interest group info.
  final String? sigInfo;

  /// The location's reference of [program], or null.
  String? of(ReferenceProgram program) => switch (program) {
    ReferenceProgram.sota => sota,
    ReferenceProgram.pota => pota,
    ReferenceProgram.wwff => wwff,
  };

  /// Whether the location carries exactly [reference] for [program]
  /// (ignoring case and surrounding space).
  bool matches(ReferenceProgram program, String reference) {
    final own = of(program)?.trim().toUpperCase();
    return own != null && own == reference.trim().toUpperCase();
  }
}

/// Accounts and their station profiles. Tokens go to the [SecretStore].
class AccountRepository {
  /// Creates the repository.
  new(this._db, this._secrets);

  final TidelineDatabase _db;
  final SecretStore _secrets;

  /// Stores a new account and its token. Returns the account id.
  Future<String> add({
    required String label,
    required String baseUrl,
    required bool usesIndexPhp,
    required String token,
    required Set<String> scopes,
    required bool hasContestSessions,
    required int nowMillis,
    bool allowHttpLan = false,
    String? certPinSha256,
    int? tokenExpiresAt,
  }) async {
    final id = newUuidV4();
    // Token first: an account row without a token would be unusable.
    await _secrets.write(SecretKeys.accountToken(id), token);
    await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: id,
            label: label,
            baseUrl: baseUrl,
            usesIndexPhp: Value(usesIndexPhp),
            allowHttpLan: Value(allowHttpLan),
            certPinSha256: Value(certPinSha256),
            scopes: Value(jsonEncode(scopes.toList()..sort())),
            serverCaps: Value(
              jsonEncode({'contestSessions': hasContestSessions}),
            ),
            tokenExpiresAt: Value(tokenExpiresAt),
            createdAt: nowMillis,
          ),
        );
    return id;
  }

  /// The account's token, or null if it is missing from the secure store.
  Future<String?> tokenFor(String accountId) =>
      _secrets.read(SecretKeys.accountToken(accountId));

  /// Replaces the token (e.g. after expiry) and the probed facts.
  Future<void> replaceToken(
    String accountId, {
    required String token,
    required Set<String> scopes,
    int? tokenExpiresAt,
  }) async {
    await _secrets.write(SecretKeys.accountToken(accountId), token);
    await (_db.update(
      _db.accounts,
    )..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(
        scopes: Value(jsonEncode(scopes.toList()..sort())),
        tokenExpiresAt: Value(tokenExpiresAt),
      ),
    );
  }

  /// Updates probed server facts.
  Future<void> updateCapabilities(
    String accountId, {
    required bool usesIndexPhp,
    required Set<String> scopes,
    required bool hasContestSessions,
    int? tokenExpiresAt,
  }) => (_db.update(_db.accounts)..where((a) => a.id.equals(accountId))).write(
    AccountsCompanion(
      usesIndexPhp: Value(usesIndexPhp),
      scopes: Value(jsonEncode(scopes.toList()..sort())),
      serverCaps: Value(jsonEncode({'contestSessions': hasContestSessions})),
      tokenExpiresAt: Value(tokenExpiresAt),
    ),
  );

  /// Removes the account, its token and all its local data.
  Future<void> remove(String accountId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.qsoSync,
      )..where((s) => s.accountId.equals(accountId))).go();
      await (_db.delete(
        _db.syncJournal,
      )..where((s) => s.accountId.equals(accountId))).go();
      await (_db.delete(
        _db.qsos,
      )..where((q) => q.accountId.equals(accountId))).go();
      await (_db.delete(
        _db.stationProfiles,
      )..where((s) => s.accountId.equals(accountId))).go();
      await (_db.delete(
        _db.accounts,
      )..where((a) => a.id.equals(accountId))).go();
    });
    await _secrets.delete(SecretKeys.accountToken(accountId));
  }

  /// All accounts.
  Stream<List<Account>> watchAll() =>
      (_db.select(_db.accounts)
            ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
          .watch()
          .map((rows) => rows.map(_toAccount).toList());

  /// One account, or null.
  Future<Account?> find(String id) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toAccount(row);
  }

  Account _toAccount(AccountRow r) {
    final caps = jsonDecode(r.serverCaps) as Map<String, dynamic>;
    return Account(
      id: r.id,
      label: r.label,
      baseUrl: r.baseUrl,
      usesIndexPhp: r.usesIndexPhp,
      allowHttpLan: r.allowHttpLan,
      certPinSha256: r.certPinSha256,
      scopes: {...(jsonDecode(r.scopes) as List).map((s) => '$s')},
      hasContestSessions: caps['contestSessions'] == true,
      tokenExpiresAt: r.tokenExpiresAt,
    );
  }

  /// Replaces the cached station list of [accountId] with [stations]
  /// (remote id, name, callsign, grid, active). Local ids stay stable for
  /// stations that still exist; QSOs keep pointing at them.
  Future<void> syncStations(
    String accountId,
    List<
      ({int remoteId, String name, String callsign, String? grid, bool active})
    >
    stations, {
    required int nowMillis,
    Map<int, StationReferences> references = const {},
  }) => _db.transaction(() async {
    final existing = await (_db.select(
      _db.stationProfiles,
    )..where((s) => s.accountId.equals(accountId))).get();
    final byRemote = {for (final s in existing) s.remoteId: s};
    for (final s in stations) {
      final row = byRemote.remove(s.remoteId);
      await _db
          .into(_db.stationProfiles)
          .insertOnConflictUpdate(
            StationProfilesCompanion.insert(
              id: row?.id ?? newUuidV4(),
              accountId: accountId,
              remoteId: s.remoteId,
              name: s.name,
              callsign: s.callsign,
              gridsquare: Value(s.grid),
              sotaRef: Value(references[s.remoteId]?.sota),
              potaRef: Value(references[s.remoteId]?.pota),
              wwffRef: Value(references[s.remoteId]?.wwff),
              iota: Value(references[s.remoteId]?.iota),
              sig: Value(references[s.remoteId]?.sig),
              sigInfo: Value(references[s.remoteId]?.sigInfo),
              active: Value(s.active),
              fetchedAt: nowMillis,
            ),
          );
    }
    // Stations removed on the server stay cached if QSOs reference them,
    // so those QSOs can still show where they were logged.
  });

  /// Station profiles of [accountId].
  Stream<List<StationProfile>> watchStations(String accountId) =>
      (_db.select(_db.stationProfiles)
            ..where((s) => s.accountId.equals(accountId))
            ..orderBy([(s) => OrderingTerm.asc(s.name)]))
          .watch()
          .map(
            (rows) => [
              for (final r in rows)
                StationProfile(
                  id: r.id,
                  accountId: r.accountId,
                  remoteId: r.remoteId,
                  name: r.name,
                  callsign: r.callsign,
                  gridsquare: r.gridsquare,
                  active: r.active,
                  references: StationReferences(
                    sota: r.sotaRef,
                    pota: r.potaRef,
                    wwff: r.wwffRef,
                    iota: r.iota,
                    sig: r.sig,
                    sigInfo: r.sigInfo,
                  ),
                ),
            ],
          );
}
