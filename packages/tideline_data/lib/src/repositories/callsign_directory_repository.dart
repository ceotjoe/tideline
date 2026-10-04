import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// What the QSO history knows about one station.
@immutable
class CallsignInfo {
  /// Creates an entry.
  const new({
    required this.call,
    required this.lastTime,
    this.name,
    this.qth,
    this.gridsquare,
    this.country,
    this.state,
    this.dxcc,
    this.cqz,
    this.ituz,
  });

  /// The home callsign.
  final String call;

  /// Start of the newest QSO the values come from (UTC millis).
  final int lastTime;

  /// Operator name.
  final String? name;

  /// Town or place.
  final String? qth;

  /// Maidenhead locator.
  final String? gridsquare;

  /// Country name as logged.
  final String? country;

  /// State, province or similar.
  final String? state;

  /// DXCC entity number.
  final int? dxcc;

  /// CQ zone.
  final int? cqz;

  /// ITU zone.
  final int? ituz;

  /// Whether there is nothing but the call and a time.
  bool get isBare =>
      name == null &&
      qth == null &&
      gridsquare == null &&
      country == null &&
      state == null;

  @override
  bool operator ==(Object other) =>
      other is CallsignInfo &&
      other.call == call &&
      other.lastTime == lastTime &&
      other.name == name &&
      other.qth == qth &&
      other.gridsquare == gridsquare &&
      other.country == country &&
      other.state == state &&
      other.dxcc == dxcc &&
      other.cqz == cqz &&
      other.ituz == ituz;

  @override
  int get hashCode => Object.hash(
    call,
    lastTime,
    name,
    qth,
    gridsquare,
    country,
    state,
    dxcc,
    cqz,
    ituz,
  );
}

/// One QSO's worth of values to merge into the directory.
typedef DirectoryObservation = ({
  String call,
  int time,
  String? name,
  String? qth,
  String? gridsquare,
  String? country,
  String? state,
  int? dxcc,
  int? cqz,
  int? ituz,
});

/// The offline callsign directory: what the QSO history says about the
/// stations you worked (name, place, locator, zones), per account.
///
/// Derived data: it is built from the local log and from the server's ADIF
/// export (the same pull as the worked-before index), updated when a QSO is
/// saved, and can be rebuilt at any time. It only suggests values; it never
/// changes a QSO.
class CallsignDirectoryRepository {
  /// Creates the repository.
  new(this._db);

  final TidelineDatabase _db;

  /// A server pull stops adding new stations to an account's directory beyond
  /// this many (a crafted or enormous export cannot grow it without bound).
  static const int maxRowsPerAccount = 500000;

  /// The cap in force ([maxRowsPerAccount]); a test lowers it.
  @visibleForTesting
  int get maxRows => maxRowsPerAccount;

  static const int _maxText = 80;

  /// Every value of the newest QSO that has it wins.
  static String _newest(String column) =>
      '$column = CASE WHEN excluded.$column IS NOT NULL AND '
      '($column IS NULL OR excluded.last_time >= last_time) '
      'THEN excluded.$column ELSE $column END';

  static const _directoryColumns = [
    'name',
    'qth',
    'gridsquare',
    'country',
    'state',
    'dxcc',
    'cqz',
    'ituz',
  ];

  static final String _upsertTail =
      'ON CONFLICT(account_id, call) DO UPDATE SET '
      '${_directoryColumns.map(_newest).join(', ')}, '
      'last_time = MAX(last_time, excluded.last_time)';

  static const String _columns =
      '(account_id, call, name, qth, gridsquare, country, state, dxcc, cqz, '
      'ituz, last_time)';

  static final String _upsert =
      'INSERT INTO callsign_directory $_columns '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) $_upsertTail';

  /// Like [_upsert], but only for a station already in the directory: used
  /// once the account is at the cap.
  static final String _upsertKnownOnly =
      'INSERT INTO callsign_directory $_columns '
      'SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? WHERE EXISTS ( '
      'SELECT 1 FROM callsign_directory WHERE account_id = ? AND call = ?) '
      '$_upsertTail';

  /// Trims, removes control characters and limits the length; null if empty.
  @visibleForTesting
  static String? cleanText(String? value, {int max = _maxText}) {
    if (value == null) return null;
    final text = value
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) return null;
    return text.length > max ? text.substring(0, max) : text;
  }

  static int? _intIn(String? value, int min, int max) {
    final n = int.tryParse((value ?? '').trim());
    return n != null && n >= min && n <= max ? n : null;
  }

  /// The observation made by a QSO with the ADIF values [fields]
  /// (`NAME`, `QTH`, `GRIDSQUARE`, …), or null when its call has no home
  /// call or the QSO says nothing about the station.
  static DirectoryObservation? observe(
    String call,
    int time,
    Map<String, String?> fields,
  ) {
    final base = Callsign.tryParse(call)?.baseCall;
    if (base == null) return null;
    final grid = fields['GRIDSQUARE']?.trim();
    final obs = (
      call: base,
      time: time,
      name: cleanText(fields['NAME']),
      qth: cleanText(fields['QTH']),
      gridsquare: grid == null || grid.isEmpty
          ? null
          : Maidenhead.normalize(grid),
      country: cleanText(fields['COUNTRY'], max: 60),
      state: cleanText(fields['STATE'], max: 20),
      dxcc: _intIn(fields['DXCC'], 1, 999),
      cqz: _intIn(fields['CQZ'], 1, 40),
      ituz: _intIn(fields['ITUZ'], 1, 90),
    );
    final empty =
        obs.name == null &&
        obs.qth == null &&
        obs.gridsquare == null &&
        obs.country == null &&
        obs.state == null &&
        obs.dxcc == null &&
        obs.cqz == null &&
        obs.ituz == null;
    return empty ? null : obs;
  }

  List<Object?> _args(String accountId, DirectoryObservation o) => [
    accountId,
    o.call,
    o.name,
    o.qth,
    o.gridsquare,
    o.country,
    o.state,
    o.dxcc,
    o.cqz,
    o.ituz,
    o.time,
  ];

  void _notify() => _db.markTablesUpdated([_db.callsignDirectory]);

  /// Merges what [qso] says about its station. Called inside the transaction
  /// that stores the QSO.
  Future<void> noteQso(Qso qso) async {
    final obs = observe(qso.call.value, qso.timeOn.millis, {
      for (final k in const [
        'NAME',
        'QTH',
        'GRIDSQUARE',
        'COUNTRY',
        'STATE',
        'DXCC',
        'CQZ',
        'ITUZ',
      ])
        k: qso.field(k),
    });
    if (obs == null) return;
    await _db.customStatement(_upsert, _args(qso.accountId, obs));
    _notify();
  }

  /// Merges observations from the server's ADIF export. New stations are
  /// refused once the account holds [maxRowsPerAccount].
  Future<void> mergeServer(
    String accountId,
    List<DirectoryObservation> observations,
  ) async {
    if (observations.isEmpty) return;
    final full = await count(accountId) >= maxRows;
    await _db.transaction(() async {
      await _db.batch((b) {
        for (final o in observations) {
          if (full) {
            b.customStatement(_upsertKnownOnly, [
              ..._args(accountId, o),
              accountId,
              o.call,
            ]);
          } else {
            b.customStatement(_upsert, _args(accountId, o));
          }
        }
      });
    });
    _notify();
  }

  /// Merges the account's local log: every non-deleted QSO, oldest first, so
  /// the newest values win. Idempotent.
  Future<void> rebuildLocal(String accountId) async {
    final rows =
        await (_db.select(_db.qsos)
              ..where(
                (q) => q.accountId.equals(accountId) & q.deletedAt.isNull(),
              )
              ..orderBy([(q) => OrderingTerm.asc(q.timeOn)]))
            .get();
    // Keep only the newest value per call and field, then write one row per
    // call (cheaper than one upsert per QSO for a large log).
    final byCall = <String, DirectoryObservation>{};
    for (final q in rows) {
      final extra = _extra(q.adifExtra);
      final obs = observe(q.call, q.timeOn, {
        'NAME': q.name,
        'QTH': q.qth,
        'GRIDSQUARE': q.gridsquare,
        'COUNTRY': q.country,
        'STATE': q.state,
        'DXCC': q.dxcc?.toString(),
        'CQZ': q.cqz?.toString(),
        'ITUZ': q.ituz?.toString(),
        ...{
          for (final MapEntry(:key, :value) in extra.entries)
            if (key == 'COUNTRY' || key == 'STATE') key: value,
        },
      });
      if (obs == null) continue;
      final old = byCall[obs.call];
      byCall[obs.call] = old == null ? obs : _newer(old, obs);
    }
    await _db.transaction(() async {
      await _db.batch((b) {
        for (final o in byCall.values) {
          b.customStatement(_upsert, _args(accountId, o));
        }
      });
    });
    _notify();
  }

  Map<String, String> _extra(String json) {
    try {
      final m = jsonDecode(json);
      if (m is! Map) return const {};
      return {
        for (final e in m.entries)
          if (e.value is String) '${e.key}'.toUpperCase(): e.value as String,
      };
    } on FormatException {
      return const {};
    }
  }

  /// [b] (newer or equal) over [a], each value falling back to the other.
  DirectoryObservation _newer(DirectoryObservation a, DirectoryObservation b) =>
      (
        call: a.call,
        time: b.time >= a.time ? b.time : a.time,
        name: b.name ?? a.name,
        qth: b.qth ?? a.qth,
        gridsquare: b.gridsquare ?? a.gridsquare,
        country: b.country ?? a.country,
        state: b.state ?? a.state,
        dxcc: b.dxcc ?? a.dxcc,
        cqz: b.cqz ?? a.cqz,
        ituz: b.ituz ?? a.ituz,
      );

  /// Removes everything of [accountId].
  Future<void> clear(String accountId) async {
    await (_db.delete(
      _db.callsignDirectory,
    )..where((d) => d.accountId.equals(accountId))).go();
  }

  /// Number of stations known for [accountId].
  Future<int> count(String accountId) => watchCount(accountId).first;

  /// [count] as a stream.
  Stream<int> watchCount(String accountId) {
    final n = _db.callsignDirectory.call.count();
    return (_db.selectOnly(_db.callsignDirectory)
          ..addColumns([n])
          ..where(_db.callsignDirectory.accountId.equals(accountId)))
        .watchSingle()
        .map((row) => row.read(n) ?? 0);
  }

  /// What the history of **all accounts** knows about the home call of
  /// [call], each value from the newest QSO that has it; null when nothing
  /// is known.
  Future<CallsignInfo?> lookup(String call) async {
    final base = Callsign.tryParse(call)?.baseCall;
    if (base == null) return null;
    final rows = await (_db.select(
      _db.callsignDirectory,
    )..where((d) => d.call.equals(base))).get();
    return _merge(base, rows);
  }

  CallsignInfo? _merge(String call, List<CallsignDirectoryRow> rows) {
    if (rows.isEmpty) return null;
    final newestFirst = [...rows]
      ..sort((a, b) => b.lastTime.compareTo(a.lastTime));
    T? pick<T>(T? Function(CallsignDirectoryRow) of) {
      for (final r in newestFirst) {
        final v = of(r);
        if (v != null) return v;
      }
      return null;
    }

    return CallsignInfo(
      call: call,
      lastTime: newestFirst.first.lastTime,
      name: pick((r) => r.name),
      qth: pick((r) => r.qth),
      gridsquare: pick((r) => r.gridsquare),
      country: pick((r) => r.country),
      state: pick((r) => r.state),
      dxcc: pick((r) => r.dxcc),
      cqz: pick((r) => r.cqz),
      ituz: pick((r) => r.ituz),
    );
  }

  /// Stations whose call starts with [query], or whose name or place
  /// contains it (case-insensitive), newest contact first, merged over all
  /// accounts. An empty query lists the most recent ones.
  Future<List<CallsignInfo>> search(String query, {int limit = 100}) async {
    final q = query.trim();
    final like = q
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final rows =
        await (_db.select(_db.callsignDirectory)
              ..where(
                (d) => q.isEmpty
                    ? const Constant(true)
                    : d.call.like('${like.toUpperCase()}%', escapeChar: r'\') |
                          d.name.like('%$like%', escapeChar: r'\') |
                          d.qth.like('%$like%', escapeChar: r'\'),
              )
              ..orderBy([(d) => OrderingTerm.desc(d.lastTime)])
              ..limit(limit * 3))
            .get();
    final byCall = <String, List<CallsignDirectoryRow>>{};
    for (final r in rows) {
      byCall.putIfAbsent(r.call, () => []).add(r);
    }
    final merged = [for (final e in byCall.entries) ?_merge(e.key, e.value)]
      ..sort((a, b) => b.lastTime.compareTo(a.lastTime));
    return merged.take(limit).toList();
  }
}
