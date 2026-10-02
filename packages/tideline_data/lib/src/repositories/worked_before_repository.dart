import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_data/src/repositories/settings_store.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// How a contact on a given band and mode relates to what was worked before.
enum WorkedSlotStatus {
  /// The call was never worked.
  newCall,

  /// Worked, but never on this band.
  newBand,

  /// Worked, on this band, but never in this mode (or on another band in
  /// this mode, and this band is also new: then [newBand] wins).
  newMode,

  /// Band and mode were each worked, but not together.
  newSlot,

  /// Already worked on this band and mode.
  workedBefore,
}

/// What is known about contacts with one call.
@immutable
class WorkedSummary {
  /// Creates a summary.
  const new({
    required this.bands,
    required this.modes,
    required this.slots,
    this.firstTime,
  });

  /// Nothing worked.
  static const WorkedSummary none = WorkedSummary(
    bands: {},
    modes: {},
    slots: {},
  );

  /// Band names worked.
  final Set<String> bands;

  /// ADIF modes worked.
  final Set<String> modes;

  /// (band, mode) pairs worked.
  final Set<(String, String)> slots;

  /// Earliest contact (UTC millis), or null.
  final int? firstTime;

  /// Whether the call was worked at all.
  bool get worked => slots.isNotEmpty;

  /// Classifies a contact on [band] in [mode] (ADIF mode, upper case).
  WorkedSlotStatus slotStatus(String band, String mode) {
    if (!worked) return WorkedSlotStatus.newCall;
    if (!bands.contains(band)) return WorkedSlotStatus.newBand;
    if (!modes.contains(mode)) return WorkedSlotStatus.newMode;
    if (!slots.contains((band, mode))) return WorkedSlotStatus.newSlot;
    return WorkedSlotStatus.workedBefore;
  }
}

/// The derived "worked before" index: local QSOs plus the server's ADIF
/// pull. Rebuildable at any time.
class WorkedBeforeRepository {
  /// Creates the repository.
  new(this._db) : _settings = SettingsStore(_db);

  final TidelineDatabase _db;
  final SettingsStore _settings;

  static const String _upsert =
      'INSERT INTO worked_before '
      '(account_id, call, band, mode, dxcc, gridsquare, first_time, source) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?) '
      'ON CONFLICT(account_id, call, band, mode) DO UPDATE SET '
      'first_time = MIN(first_time, excluded.first_time), '
      'dxcc = COALESCE(excluded.dxcc, dxcc), '
      'gridsquare = COALESCE(excluded.gridsquare, gridsquare), '
      'source = CASE WHEN ? THEN excluded.source ELSE source END';

  String _cursorKey(String accountId) =>
      'workedBefore.$accountId.lastFetchedId';

  /// Rebuilds the `local` entries of [accountId] from its non-deleted QSOs.
  /// Entries that came from the server stay (their time is lowered when a
  /// local QSO is older).
  Future<void> rebuildLocal(String accountId) => _db.transaction(() async {
    await _db.customStatement(
      "DELETE FROM worked_before WHERE account_id = ? AND source = 'local'",
      [accountId],
    );
    final rows = await _db
        .customSelect(
          'SELECT UPPER(call) AS c, band, mode, MIN(time_on) AS t, '
          'MAX(dxcc) AS d, MAX(gridsquare) AS g FROM qsos '
          'WHERE account_id = ? AND deleted_at IS NULL GROUP BY 1, 2, 3',
          variables: [Variable<String>(accountId)],
        )
        .get();
    await _db.batch((b) {
      for (final r in rows) {
        b.customStatement(_upsert, [
          accountId,
          r.read<String>('c'),
          r.read<String>('band'),
          r.read<String>('mode'),
          r.readNullable<int>('d'),
          r.readNullable<String>('g'),
          r.read<int>('t'),
          'local',
          false,
        ]);
      }
    });
  });

  /// Merges an ADIF export of the server's log. Returns how many records were
  /// used and how many skipped (no call, band, mode or time).
  Future<({int merged, int skipped})> mergeServerAdif(
    String accountId,
    String adif,
  ) async {
    final doc = const AdiParser().parse(utf8.encode(adif));
    var merged = 0;
    final args = <List<Object?>>[];
    for (final r in doc.records) {
      final call = r['CALL']?.trim().toUpperCase();
      final rawMode = r['MODE']?.trim().toUpperCase();
      final band = _bandOf(r);
      final time = UtcDateTime.tryParseAdif(
        r['QSO_DATE'] ?? '',
        (r['TIME_ON'] ?? '000000').padRight(6, '0'),
      );
      if (call == null ||
          call.isEmpty ||
          rawMode == null ||
          rawMode.isEmpty ||
          band == null ||
          time == null) {
        continue;
      }
      final mode =
          Mode.tryParse(rawMode, submode: r['SUBMODE'])?.mode ?? rawMode;
      final grid = r['GRIDSQUARE']?.trim();
      final gridValue = grid == null || grid.isEmpty
          ? null
          : grid.toUpperCase();
      args.add([
        accountId,
        call,
        band,
        mode,
        int.tryParse(r['DXCC'] ?? ''),
        gridValue,
        time.millis,
        'server',
        true,
      ]);
      merged++;
    }
    await _db.transaction(() async {
      await _db.batch((b) {
        for (final a in args) {
          b.customStatement(_upsert, a);
        }
      });
    });
    return (merged: merged, skipped: doc.records.length - merged);
  }

  String? _bandOf(Map<String, String> record) {
    final named = Band.tryParse(record['BAND'] ?? '');
    if (named != null) return named.name;
    final mhz = double.tryParse(record['FREQ'] ?? '');
    if (mhz == null) return null;
    return Band.forFrequency((mhz * 1e6).round())?.name;
  }

  /// The ADIF pull cursor (`lastfetchedid`) of [accountId], or null.
  Future<int?> lastFetchedId(String accountId) async {
    final all = await _settings.readAll();
    return int.tryParse(all[_cursorKey(accountId)] ?? '');
  }

  /// Stores the ADIF pull cursor; null removes it.
  Future<void> setLastFetchedId(String accountId, int? id) =>
      _settings.write(_cursorKey(accountId), id?.toString());

  /// Removes everything known for [accountId], including the cursor, for a
  /// full rebuild.
  Future<void> clear(String accountId) => _db.transaction(() async {
    await (_db.delete(
      _db.workedBefore,
    )..where((w) => w.accountId.equals(accountId))).go();
    await setLastFetchedId(accountId, null);
  });

  /// What was worked with exactly [call] (so `DL1ABC/P` and `DL1ABC` are
  /// different stations).
  Future<WorkedSummary> lookup(String accountId, String call) async {
    final rows =
        await (_db.select(_db.workedBefore)..where(
              (w) =>
                  w.accountId.equals(accountId) &
                  w.call.equals(call.trim().toUpperCase()),
            ))
            .get();
    return _summarise(rows);
  }

  /// What was worked with any variant of the same home call
  /// (`EA8/DL1ABC/P` counts for `DL1ABC`).
  Future<WorkedSummary> lookupBase(String accountId, String call) async {
    final parsed = Callsign.tryParse(call);
    if (parsed == null) return await lookup(accountId, call);
    final base = parsed.baseCall;
    final rows =
        await (_db.select(_db.workedBefore)..where(
              (w) => w.accountId.equals(accountId) & w.call.like('%$base%'),
            ))
            .get();
    return _summarise([
      for (final r in rows)
        if (Callsign.tryParse(r.call)?.baseCall == base) r,
    ]);
  }

  WorkedSummary _summarise(List<WorkedBeforeRow> rows) {
    if (rows.isEmpty) return WorkedSummary.none;
    return WorkedSummary(
      bands: {for (final r in rows) r.band},
      modes: {for (final r in rows) r.mode},
      slots: {for (final r in rows) (r.band, r.mode)},
      firstTime: rows.map((r) => r.firstTime).reduce((a, b) => a < b ? a : b),
    );
  }
}
