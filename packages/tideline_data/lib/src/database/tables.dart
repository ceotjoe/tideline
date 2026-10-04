// Schema of the Tideline database. See docs/architecture/data-model.md.
//
// Conventions:
// * User-data rows use UUID text primary keys.
// * All instants are UTC epoch milliseconds (int). Never local time.
// * Rows that sync between devices carry `origin_device_id`, `hlc_created`,
//   `hlc_modified`, `rev` and a `deleted_at` tombstone.
// * QSO columns use ADIF 3.1.x field names (snake_case of the ADIF name).

// Column getters are named after their ADIF fields and documented in
// docs/architecture/data-model.md; only non-obvious columns carry comments.
// ignore_for_file: public_member_api_docs

import 'package:drift/drift.dart';

/// Columns shared by every row that can sync between devices.
mixin SyncedRow on Table {
  /// Device that created the row.
  TextColumn get originDeviceId => text()();

  /// Hybrid logical clock timestamp of creation.
  TextColumn get hlcCreated => text()();

  /// Hybrid logical clock timestamp of the last change.
  TextColumn get hlcModified => text()();

  /// Local revision counter, incremented on every change.
  IntColumn get rev => integer().withDefault(const Constant(1))();

  /// Tombstone: UTC millis of deletion, or null while the row is alive.
  IntColumn get deletedAt => integer().nullable()();
}

/// A Wavelog instance and account. The token lives in the secure store.
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  TextColumn get baseUrl => text()();
  BoolColumn get usesIndexPhp => boolean().withDefault(const Constant(true))();
  TextColumn get certPinSha256 => text().nullable()();
  BoolColumn get allowHttpLan => boolean().withDefault(const Constant(false))();

  /// JSON object with probed server capabilities.
  TextColumn get serverCaps => text().withDefault(const Constant('{}'))();

  /// JSON array of granted token scopes, as reported by the server.
  TextColumn get scopes => text().withDefault(const Constant('[]'))();
  IntColumn get tokenExpiresAt => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached Wavelog station locations (`GET /station`).
@DataClassName('StationProfileRow')
class StationProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(Accounts, #id)();

  /// Wavelog `station_profile_id`.
  IntColumn get remoteId => integer()();
  TextColumn get name => text()();
  TextColumn get callsign => text()();
  TextColumn get gridsquare => text().nullable()();
  IntColumn get dxcc => integer().nullable()();
  IntColumn get cqz => integer().nullable()();
  IntColumn get ituz => integer().nullable()();
  TextColumn get sotaRef => text().nullable()();
  TextColumn get potaRef => text().nullable()();
  TextColumn get wwffRef => text().nullable()();
  TextColumn get iota => text().nullable()();
  TextColumn get sig => text().nullable()();
  TextColumn get sigInfo => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(false))();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {accountId, remoteId},
  ];
}

/// A logged contact. Column names follow ADIF 3.1.x.
@DataClassName('QsoRow')
@TableIndex(name: 'qsos_account_time', columns: {#accountId, #timeOn})
@TableIndex(name: 'qsos_call', columns: {#call})
@TableIndex(name: 'qsos_contest_session', columns: {#contestSessionId})
class Qsos extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(Accounts, #id)();

  /// Null while the QSO is a draft without a station location.
  TextColumn get stationProfileId =>
      text().nullable().references(StationProfiles, #id)();

  // Core ADIF fields.
  TextColumn get call => text()();

  /// ADIF QSO_DATE + TIME_ON as UTC epoch milliseconds.
  IntColumn get timeOn => integer()();

  /// ADIF QSO_DATE_OFF + TIME_OFF as UTC epoch milliseconds.
  IntColumn get timeOff => integer().nullable()();
  TextColumn get band => text()();
  TextColumn get bandRx => text().nullable()();
  TextColumn get mode => text()();
  TextColumn get submode => text().nullable()();

  /// ADIF FREQ in integer hertz (ADIF itself uses MHz).
  IntColumn get freqHz => integer().nullable()();

  /// ADIF FREQ_RX in integer hertz.
  IntColumn get freqRxHz => integer().nullable()();
  TextColumn get rstSent => text().nullable()();
  TextColumn get rstRcvd => text().nullable()();

  // Contacted station.
  TextColumn get name => text().nullable()();
  TextColumn get qth => text().nullable()();
  TextColumn get gridsquare => text().nullable()();
  IntColumn get dxcc => integer().nullable()();
  IntColumn get cqz => integer().nullable()();
  IntColumn get ituz => integer().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get cnty => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get cont => text().nullable()();
  TextColumn get darcDok => text().nullable()();
  TextColumn get iota => text().nullable()();

  // Award programs.
  TextColumn get sotaRef => text().nullable()();
  TextColumn get potaRef => text().nullable()();
  TextColumn get wwffRef => text().nullable()();
  TextColumn get sig => text().nullable()();
  TextColumn get sigInfo => text().nullable()();
  TextColumn get mySotaRef => text().nullable()();
  TextColumn get myPotaRef => text().nullable()();
  TextColumn get myWwffRef => text().nullable()();
  TextColumn get mySig => text().nullable()();
  TextColumn get mySigInfo => text().nullable()();

  // Own station.
  TextColumn get stationCallsign => text().nullable()();
  TextColumn get operator => text().nullable()();
  TextColumn get myGridsquare => text().nullable()();

  /// ADIF TX_PWR in watts.
  RealColumn get txPwr => real().nullable()();

  // Contest.
  TextColumn get contestId => text().nullable()();
  IntColumn get srx => integer().nullable()();
  IntColumn get stx => integer().nullable()();
  TextColumn get srxString => text().nullable()();
  TextColumn get stxString => text().nullable()();
  TextColumn get check => text().nullable()();
  TextColumn get qsoClass => text().named('class').nullable()();
  TextColumn get precedence => text().nullable()();
  TextColumn get arrlSect => text().nullable()();

  // Other.
  TextColumn get propMode => text().nullable()();
  TextColumn get satName => text().nullable()();
  TextColumn get satMode => text().nullable()();
  TextColumn get comment => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get qslVia => text().nullable()();

  /// JSON object of every other ADIF field (`FIELD_NAME` → value), so that
  /// import and export are lossless.
  TextColumn get adifExtra => text().withDefault(const Constant('{}'))();

  // Provenance.
  TextColumn get contestSessionId =>
      text().nullable().references(ContestSessions, #id)();
  TextColumn get activationId =>
      text().nullable().references(Activations, #id)();

  /// `manual`, `fle`, `import`, `peer` or `wsjtx`.
  TextColumn get source => text().withDefault(const Constant('manual'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Sync status of a QSO for its account.
@DataClassName('QsoSyncRow')
@TableIndex(name: 'qso_sync_account_state', columns: {#accountId, #state})
class QsoSync extends Table {
  TextColumn get qsoId => text().references(Qsos, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();

  /// `SyncState.name` from tideline_domain.
  TextColumn get state => text()();

  /// `SyncOperation.name` from tideline_domain.
  TextColumn get operation => text().withDefault(const Constant('create'))();

  /// Wavelog QSO id, once known.
  IntColumn get remoteQsoId => integer().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAt => integer().nullable()();
  TextColumn get lastErrorCode => text().nullable()();

  /// Localisation key of the plain-language explanation.
  TextColumn get lastErrorKey => text().nullable()();

  /// The server's own message, redacted.
  TextColumn get serverMessage => text().nullable()();
  IntColumn get syncedRev => integer().nullable()();
  TextColumn get syncedHash => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {qsoId, accountId};
}

/// Append-only, user-visible history of sync steps.
@DataClassName('SyncJournalRow')
@TableIndex(name: 'sync_journal_account_at', columns: {#accountId, #at})
class SyncJournal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get qsoId => text().nullable()();
  IntColumn get at => integer()();
  TextColumn get event => text()();

  /// Redacted JSON detail.
  TextColumn get detail => text().withDefault(const Constant('{}'))();
}

/// Contest definitions (data, not code).
@DataClassName('ContestDefinitionRow')
class ContestDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get cabrilloName => text().nullable()();

  /// ADIF CONTEST_ID / Wavelog contest ADIF name.
  TextColumn get wavelogAdifName => text().nullable()();
  IntColumn get version => integer()();

  /// JSON: exchange fields, dupe rule, multipliers, scoring.
  TextColumn get definition => text()();
  BoolColumn get builtin => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A contest operating session.
@DataClassName('ContestSessionRow')
class ContestSessions extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get definitionId => text().references(ContestDefinitions, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get stationProfileId =>
      text().nullable().references(StationProfiles, #id)();
  IntColumn get startedAt => integer()();
  IntColumn get endedAt => integer().nullable()();

  /// JSON session settings (own exchange, serial options, …).
  TextColumn get settings => text().withDefault(const Constant('{}'))();

  /// Wavelog contest session id (Wavelog 3.2+), once created.
  IntColumn get remoteSessionId => integer().nullable()();

  /// `single`, `prefix` or `range` (multi-operator serial strategies).
  TextColumn get serialStrategy =>
      text().withDefault(const Constant('single'))();
  IntColumn get serialRangeStart => integer().nullable()();
  IntColumn get serialRangeEnd => integer().nullable()();

  /// Whether and how the session exists on Wavelog: `local` (never synced),
  /// `pending` (to be created), `verifying` (a create request was in flight;
  /// reconcile first) or `created`.
  TextColumn get remoteState => text().withDefault(const Constant('local'))();

  /// The end time last sent to Wavelog (UTC millis), null if none was.
  IntColumn get remoteEndSynced => integer().nullable()();

  /// Localisation key of the last session-sync error.
  TextColumn get remoteErrorKey => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// QSOs that have been linked to a contest session on the Wavelog server.
@DataClassName('ContestLinkRow')
class ContestLinks extends Table {
  TextColumn get sessionId => text().references(ContestSessions, #id)();
  TextColumn get qsoId => text().references(Qsos, #id)();

  /// Wavelog QSO id that was linked.
  IntColumn get remoteQsoId => integer()();
  IntColumn get linkedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, qsoId};
}

/// Sent serial numbers. Monotonic per session and never reused, even after
/// the QSO is edited or deleted.
@DataClassName('SerialAllocationRow')
class SerialAllocations extends Table {
  TextColumn get sessionId => text().references(ContestSessions, #id)();
  IntColumn get serial => integer()();

  /// Null once the QSO that used the serial was deleted.
  TextColumn get qsoId => text().nullable()();
  IntColumn get allocatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, serial};
}

/// A SOTA/POTA/WWFF/… activation.
@DataClassName('ActivationRow')
class Activations extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get program => text()();
  TextColumn get reference => text()();
  TextColumn get myGridsquare => text().nullable()();
  TextColumn get stationProfileId =>
      text().nullable().references(StationProfiles, #id)();
  IntColumn get startedAt => integer()();
  IntColumn get endedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Validity rules per award program (data, not code).
@DataClassName('ProgramRuleRow')
class ProgramRules extends Table {
  TextColumn get program => text()();
  IntColumn get version => integer()();

  /// JSON: validity threshold, per-band/mode rules.
  TextColumn get rules => text()();

  @override
  Set<Column<Object>> get primaryKey => {program};
}

/// Metadata of an installed offline reference pack.
@DataClassName('ReferencePackRow')
class ReferencePacks extends Table {
  TextColumn get id => text()();

  /// `dxcc`, `sota`, `pota`, `wwff`, `iota` or `scp`.
  TextColumn get kind => text()();
  TextColumn get version => text()();
  TextColumn get sourceUrl => text()();
  TextColumn get sha256 => text()();
  IntColumn get fetchedAt => integer()();
  TextColumn get regionFilter => text().nullable()();
  TextColumn get licenceNote => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// DXCC entities from the bundled or downloaded country data.
@DataClassName('DxccEntityRow')
class DxccEntities extends Table {
  IntColumn get dxcc => integer()();
  TextColumn get name => text()();
  TextColumn get prefix => text()();
  IntColumn get cqz => integer()();
  IntColumn get ituz => integer()();
  TextColumn get cont => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {dxcc};
}

/// Prefixes and exact-callsign exceptions mapping to DXCC entities.
@DataClassName('DxccPrefixRow')
class DxccPrefixes extends Table {
  TextColumn get prefixOrCall => text()();

  /// True for full-callsign exceptions (`=CALL` in cty.dat).
  BoolColumn get exact => boolean()();
  IntColumn get dxcc => integer().references(DxccEntities, #dxcc)();
  IntColumn get cqzOverride => integer().nullable()();
  IntColumn get ituzOverride => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {prefixOrCall, exact};
}

/// Award program references (summits, parks, …).
@DataClassName('ProgramReferenceRow')
@TableIndex(
  name: 'program_references_position',
  columns: {#program, #lat, #lon},
)
class ProgramReferences extends Table {
  TextColumn get program => text()();
  TextColumn get ref => text()();
  TextColumn get name => text()();
  TextColumn get region => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  IntColumn get validFrom => integer().nullable()();
  IntColumn get validTo => integer().nullable()();

  /// False when the source marks the reference as retired or inactive.
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {program, ref};
}

/// Super-check-partial callsigns (MASTER.SCP).
@DataClassName('ScpCallRow')
class ScpCalls extends Table {
  TextColumn get call => text()();

  @override
  Set<Column<Object>> get primaryKey => {call};
}

/// Derived "worked before" index; rebuildable at any time.
@DataClassName('WorkedBeforeRow')
class WorkedBefore extends Table {
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get call => text()();
  TextColumn get band => text()();
  TextColumn get mode => text()();
  IntColumn get dxcc => integer().nullable()();
  TextColumn get gridsquare => text().nullable()();
  IntColumn get firstTime => integer()();

  /// `server` or `local`.
  TextColumn get source => text()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, call, band, mode};
}

/// A QSO whose local copy was removed to free space, because Wavelog has it
/// (`QsoEvictionRepository`). It is a record, not a delete: nothing is sent
/// to the server, and the row holds ids and a hash only (no callsign, no
/// personal data).
@DataClassName('EvictedQsoRow')
class EvictedQsos extends Table {
  /// The local id the QSO had. No foreign key: the row is gone.
  TextColumn get qsoId => text()();
  TextColumn get accountId => text().references(Accounts, #id)();

  /// The Wavelog QSO id the server keeps.
  IntColumn get remoteQsoId => integer()();

  /// When the local copy was removed (UTC millis).
  IntColumn get evictedAt => integer()();

  /// SHA-256 (hex) of the QSO's duplicate key, so a later ADIF import can
  /// tell that Wavelog already has it without the callsign being kept.
  TextColumn get dupeHash => text()();

  @override
  Set<Column<Object>> get primaryKey => {qsoId};
}

/// What is known about a station from the QSO history of an account:
/// derived data, rebuildable at any time (`CallsignDirectoryRepository`).
///
/// One row per home call (`EA8/DL1ABC/P` and `DL1ABC` share one). Each value
/// comes from the newest QSO that has it. Names and places of other people
/// are personal data; the database is encrypted at rest.
@DataClassName('CallsignDirectoryRow')
class CallsignDirectory extends Table {
  TextColumn get accountId => text().references(Accounts, #id)();

  /// The home callsign, upper case.
  TextColumn get call => text()();
  TextColumn get name => text().nullable()();
  TextColumn get qth => text().nullable()();
  TextColumn get gridsquare => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get state => text().nullable()();
  IntColumn get dxcc => integer().nullable()();
  IntColumn get cqz => integer().nullable()();
  IntColumn get ituz => integer().nullable()();

  /// Start of the newest QSO the row was built from (UTC millis).
  IntColumn get lastTime => integer()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, call};
}

/// The user's own note about a station. Local only: Wavelog's API v2 has no
/// notes resource (docs/architecture/wavelog-api.md), so notes are never sent
/// anywhere, and they are not part of any ADIF export.
@DataClassName('CallsignNoteRow')
class CallsignNotes extends Table with SyncedRow {
  TextColumn get id => text()();

  /// The home callsign, upper case. One note per station, across accounts.
  TextColumn get call => text()();

  /// The text; never empty on a live row (an empty note is a delete).
  TextColumn get body => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {call},
  ];
}

/// Paired Tideline devices (device-to-device sync, later milestone).
@DataClassName('DeviceRow')
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get publicKey => text()();
  IntColumn get pairedAt => integer()();
  IntColumn get revokedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Per-peer replication cursor.
@DataClassName('PeerCursorRow')
class PeerCursors extends Table {
  TextColumn get deviceId => text().references(Devices, #id)();
  TextColumn get lastHlc => text()();

  @override
  Set<Column<Object>> get primaryKey => {deviceId};
}

/// Key/value user settings.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// User overrides of keyboard shortcuts. Defaults live in code.
@DataClassName('ShortcutBindingRow')
class ShortcutBindings extends Table {
  TextColumn get commandId => text()();

  /// `apple`, `other` or `all`.
  TextColumn get platform => text()();

  /// Serialised key combination, or empty to unbind.
  TextColumn get binding => text()();

  @override
  Set<Column<Object>> get primaryKey => {commandId, platform};
}
