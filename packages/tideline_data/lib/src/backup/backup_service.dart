import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_data/src/backup/backup_codec.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_data/src/repositories/callsign_note_repository.dart';
import 'package:tideline_data/src/repositories/qso_repository.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// What a restore did.
@immutable
class RestoreReport {
  /// Creates a report.
  const new({
    required this.accountsAdded,
    required this.qsosAdded,
    required this.qsosSkipped,
    this.notesAdded = 0,
  });

  /// Accounts created (they need a token before they can sync).
  final int accountsAdded;

  /// QSOs restored.
  final int qsosAdded;

  /// QSOs already present (same id), left unchanged.
  final int qsosSkipped;

  /// Callsign notes restored (a station that has a note keeps it).
  final int notesAdded;
}

/// Creates and restores plain (unencrypted) backups of the whole log.
///
/// A backup contains accounts (without tokens: those never leave the
/// secure store), station locations and every QSO as an ADIF record with
/// its sync status, so restoring on a new device never duplicates QSOs in
/// Wavelog.
class BackupService {
  /// Creates the service.
  new(this._db, this._qsos, {this._codec = const BackupCodec()});

  final TidelineDatabase _db;
  final QsoRepository _qsos;
  final BackupCodec _codec;

  static const _format = 'tideline-backup';
  static const _version = 1;

  /// A plain backup file. It is not encrypted (ADR 0034).
  Future<Uint8List> create({required int nowMillis}) async {
    final accounts = await _db.select(_db.accounts).get();
    final stations = await _db.select(_db.stationProfiles).get();
    final qsos = await _qsos.all();
    final notes = await (_db.select(
      _db.callsignNotes,
    )..where((n) => n.deletedAt.isNull())).get();
    final payload = {
      'format': _format,
      'version': _version,
      'createdAt': nowMillis,
      'accounts': [
        for (final a in accounts)
          {
            'id': a.id,
            'label': a.label,
            'baseUrl': a.baseUrl,
            'usesIndexPhp': a.usesIndexPhp,
            'allowHttpLan': a.allowHttpLan,
            'certPinSha256': a.certPinSha256,
            'scopes': a.scopes,
            'serverCaps': a.serverCaps,
            'createdAt': a.createdAt,
          },
      ],
      'stations': [
        for (final s in stations)
          {
            'id': s.id,
            'accountId': s.accountId,
            'remoteId': s.remoteId,
            'name': s.name,
            'callsign': s.callsign,
            'gridsquare': s.gridsquare,
            'active': s.active,
          },
      ],
      // Local only (Wavelog has no notes API), so the backup is their only
      // second copy.
      'callsignNotes': [
        for (final n in notes)
          {
            'id': n.id,
            'call': n.call,
            'body': n.body,
            'originDeviceId': n.originDeviceId,
            'modifiedAt': n.hlcModified,
          },
      ],
      'qsos': [
        for (final item in qsos)
          {
            'id': item.qso.id,
            'accountId': item.qso.accountId,
            'stationProfileId': item.qso.stationProfileId,
            'source': item.qso.source.name,
            'record': AdifQsoMapping.toRecord(item.qso),
            if (item.status case final st?)
              'status': {
                'state': st.state.name,
                'operation': st.operation.name,
                'remoteQsoId': st.remoteQsoId,
              },
          },
      ],
    };
    return _codec.encode(utf8.encode(jsonEncode(payload)));
  }

  /// Restores a backup. Existing data is never overwritten.
  Future<RestoreReport> restore(
    List<int> file, {
    required int nowMillis,
  }) async {
    final plain = _codec.decode(file);
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
    } on Object {
      throw const BackupFormatException('payload is not JSON');
    }
    if (payload['format'] != _format || payload['version'] != _version) {
      throw const BackupFormatException('unsupported backup version');
    }
    try {
      return await _db.transaction(() async {
        var accountsAdded = 0;
        for (final a
            in (payload['accounts'] as List).cast<Map<String, dynamic>>()) {
          final exists = await (_db.select(
            _db.accounts,
          )..where((x) => x.id.equals(a['id'] as String))).getSingleOrNull();
          if (exists != null) continue;
          await _db
              .into(_db.accounts)
              .insert(
                AccountsCompanion.insert(
                  id: a['id'] as String,
                  label: a['label'] as String,
                  baseUrl: a['baseUrl'] as String,
                  usesIndexPhp: Value(a['usesIndexPhp'] as bool),
                  allowHttpLan: Value(a['allowHttpLan'] as bool),
                  certPinSha256: Value(a['certPinSha256'] as String?),
                  scopes: Value(a['scopes'] as String),
                  serverCaps: Value(a['serverCaps'] as String),
                  createdAt: a['createdAt'] as int,
                ),
              );
          accountsAdded++;
        }
        for (final s
            in (payload['stations'] as List).cast<Map<String, dynamic>>()) {
          await _db
              .into(_db.stationProfiles)
              .insert(
                StationProfilesCompanion.insert(
                  id: s['id'] as String,
                  accountId: s['accountId'] as String,
                  remoteId: s['remoteId'] as int,
                  name: s['name'] as String,
                  callsign: s['callsign'] as String,
                  gridsquare: Value(s['gridsquare'] as String?),
                  active: Value(s['active'] as bool),
                  fetchedAt: nowMillis,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
        var added = 0;
        var skipped = 0;
        for (final q
            in (payload['qsos'] as List).cast<Map<String, dynamic>>()) {
          final record = (q['record'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v as String),
          );
          final result = AdifQsoMapping.fromRecord(
            record,
            id: q['id'] as String,
            accountId: q['accountId'] as String,
            stationProfileId: q['stationProfileId'] as String?,
          );
          if (result is! AdifImported) {
            throw const BackupFormatException('invalid QSO record');
          }
          final source =
              QsoSource.values.asNameMap()[q['source']] ?? QsoSource.manual;
          final qso = Qso(
            id: result.qso.id,
            accountId: result.qso.accountId,
            stationProfileId: result.qso.stationProfileId,
            call: result.qso.call,
            timeOn: result.qso.timeOn,
            timeOff: result.qso.timeOff,
            band: result.qso.band,
            bandRx: result.qso.bandRx,
            mode: result.qso.mode,
            freqHz: result.qso.freqHz,
            freqRxHz: result.qso.freqRxHz,
            rstSent: result.qso.rstSent,
            rstRcvd: result.qso.rstRcvd,
            fields: result.qso.fields,
            source: source,
          );
          final st = q['status'] as Map<String, dynamic>?;
          final status = st == null
              ? null
              : SyncStatus(
                  state: SyncState.values.byName(st['state'] as String),
                  operation: SyncOperation.values.byName(
                    st['operation'] as String,
                  ),
                  remoteQsoId: st['remoteQsoId'] as int?,
                );
          if (await _qsos.restore(qso, status)) {
            added++;
          } else {
            skipped++;
          }
        }
        // Notes (absent in older backups). A station that already has a
        // note keeps it.
        var notesAdded = 0;
        for (final n
            in ((payload['callsignNotes'] as List?) ?? const [])
                .cast<Map<String, dynamic>>()) {
          if (await _restoreNote(n)) notesAdded++;
        }
        return RestoreReport(
          accountsAdded: accountsAdded,
          qsosAdded: added,
          qsosSkipped: skipped,
          notesAdded: notesAdded,
        );
      });
      // The payload is untrusted: a wrong type or value anywhere in it
      // (a failed `as` cast, an unknown enum name) means a corrupt backup.
      // ignore: avoid_catching_errors
    } on TypeError {
      throw const BackupFormatException('unexpected structure');
      // Same reason: an invalid enum name or value in untrusted input.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      throw const BackupFormatException('unexpected value');
    }
  }

  /// Adds a note from a backup unless the station already has one. The text is
  /// untrusted: it is limited like a typed note.
  Future<bool> _restoreNote(Map<String, dynamic> n) async {
    final call = CallsignNoteRepository.keyOf(n['call'] as String);
    final body = (n['body'] as String).trim();
    if (call == null ||
        body.isEmpty ||
        body.length > CallsignNoteRepository.maxLength) {
      return false;
    }
    final id = n['id'] as String;
    final taken = await (_db.select(
      _db.callsignNotes,
    )..where((x) => x.call.equals(call) | x.id.equals(id))).get();
    if (taken.isNotEmpty) return false;
    final at = n['modifiedAt'] as String;
    await _db
        .into(_db.callsignNotes)
        .insert(
          CallsignNotesCompanion.insert(
            id: id,
            call: call,
            body: body,
            originDeviceId: n['originDeviceId'] as String,
            hlcCreated: at,
            hlcModified: at,
          ),
        );
    return true;
  }
}
