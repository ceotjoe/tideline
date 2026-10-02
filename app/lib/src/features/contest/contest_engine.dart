import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:tideline/src/features/contest/contest_qso_codec.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Scoring, dupe and rate state of one contest session, kept up to date
/// incrementally.
///
/// [sync] receives the session's QSOs (ordered by time, as the database
/// delivers them). When the new list only appends QSOs that are not older
/// than the last one, they are scored one by one; any other change (an
/// edit, a delete, a QSO inserted in the middle) rebuilds from scratch with
/// the same algorithm as `ContestScorer.scoreAll`. Both paths are tested to
/// give identical results.
///
/// The engine is mutable and used from the UI isolate only; the provider
/// layer publishes an immutable [ContestLive] snapshot after each change.
class ContestEngine {
  /// Creates an engine for [spec]. [dxcc] resolves the other station's
  /// entity; without it multipliers by entity cannot be credited.
  new({required this.spec, this.dxcc})
    : _scorer = ContestScorer(spec.definition),
      _dupes = ContestDupeChecker(spec.definition);

  /// The session being scored.
  final ContestSpec spec;

  /// Offline DXCC data.
  final DxccDatabase? dxcc;

  ContestScorer _scorer;
  ContestDupeChecker _dupes;
  final List<int> _fingerprints = [];
  final List<Qso> _qsos = [];
  final List<UtcDateTime> _times = [];
  final Map<String, QsoScore> _scores = {};
  final Map<String, DxccMatch?> _dxccCache = {};

  /// Increases on every change; lets widgets cache derived values.
  int version = 0;

  /// How many full rebuilds happened (for tests and diagnostics).
  int rebuilds = 0;

  /// The session's QSOs, oldest first.
  List<Qso> get qsos => UnmodifiableListView(_qsos);

  /// QSO times, oldest first.
  List<UtcDateTime> get times => UnmodifiableListView(_times);

  /// The score of each QSO by id.
  Map<String, QsoScore> get scores => _scores;

  /// The running score.
  ContestScore get score => _scorer.score;

  /// Number of QSOs.
  int get length => _qsos.length;

  static int _fingerprint(Qso q) => Object.hash(
    q.id,
    q.call.value,
    q.band.name,
    q.mode,
    q.timeOn.millis,
    q.rstRcvd,
    Object.hashAllUnordered(
      q.fields.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  /// Brings the engine up to date with [qsos]. Returns whether anything
  /// changed.
  bool sync(List<Qso> qsos) {
    final fingerprints = [for (final q in qsos) _fingerprint(q)];
    var common = 0;
    final limit = _fingerprints.length < fingerprints.length
        ? _fingerprints.length
        : fingerprints.length;
    while (common < limit && _fingerprints[common] == fingerprints[common]) {
      common++;
    }
    if (common == _fingerprints.length && common == fingerprints.length) {
      return false;
    }
    final appendOnly =
        common == _fingerprints.length &&
        (_times.isEmpty || qsos[common].timeOn.millis >= _times.last.millis) &&
        _isSorted(qsos, common);
    if (appendOnly) {
      for (var i = common; i < qsos.length; i++) {
        _add(qsos[i]);
        _fingerprints.add(fingerprints[i]);
      }
    } else {
      _rebuild(qsos, fingerprints);
    }
    version++;
    return true;
  }

  static bool _isSorted(List<Qso> qsos, int from) {
    for (var i = from + 1; i < qsos.length; i++) {
      if (qsos[i].timeOn.millis < qsos[i - 1].timeOn.millis) return false;
    }
    return true;
  }

  void _rebuild(List<Qso> qsos, List<int> fingerprints) {
    rebuilds++;
    _scorer = ContestScorer(spec.definition);
    _dupes = ContestDupeChecker(spec.definition);
    _qsos.clear();
    _times.clear();
    _scores.clear();
    _fingerprints
      ..clear()
      ..addAll(fingerprints);
    // The same order ContestScorer.scoreAll uses: by time, then by position.
    final order = List<int>.generate(qsos.length, (i) => i)
      ..sort((a, b) {
        final c = qsos[a].timeOn.compareTo(qsos[b].timeOn);
        return c != 0 ? c : a.compareTo(b);
      });
    for (final i in order) {
      _add(qsos[i]);
    }
  }

  void _add(Qso q) {
    _scores[q.id] = _scorer.add(contestQso(q));
    _dupes.add(_contact(q));
    _qsos.add(q);
    _times.add(q.timeOn);
  }

  ContestContact _contact(Qso q) =>
      ContestContact(id: q.id, call: q.call.value, band: q.band, mode: q.mode);

  /// The other station for scoring: DXCC data from the resolver, with the
  /// zones, locator, state and DOK of the received exchange taking
  /// precedence.
  ContestStation themFor(String call, Map<ExchangeKind, String> rcvd) {
    final match = _dxccCache.putIfAbsent(call, () => dxcc?.resolve(call));
    final base = ContestStation.fromMatch(call, match);
    return ContestStation(
      call: call,
      dxcc: base.dxcc,
      continent: base.continent,
      cqz: _int(rcvd[ExchangeKind.cqZone]) ?? base.cqz,
      ituz: _int(rcvd[ExchangeKind.ituZone]) ?? base.ituz,
      grid: rcvd[ExchangeKind.grid] ?? base.grid,
      state: rcvd[ExchangeKind.state] ?? base.state,
      dok: rcvd[ExchangeKind.dok] ?? base.dok,
    );
  }

  static int? _int(String? s) => s == null ? null : int.tryParse(s);

  /// A scoring view of a stored QSO.
  ContestQso contestQso(Qso q) {
    final values = rcvdValuesOf(spec, q);
    final rcvd = <ExchangeKind, String>{
      for (final (i, e) in spec.exchange.rcvd.indexed)
        if (values[i].isNotEmpty) e.kind: values[i],
    };
    return ContestQso(
      id: q.id,
      call: q.call.value,
      time: q.timeOn,
      band: q.band,
      mode: q.mode,
      me: spec.me,
      them: themFor(q.call.value, rcvd),
      rcvd: rcvd,
    );
  }

  /// What logging a QSO with these values would do, without changing
  /// anything. [rcvd] holds only values that parsed.
  QsoScore preview({
    required String call,
    required Band band,
    required Mode mode,
    required Map<ExchangeKind, String> rcvd,
    String? excludeId,
  }) => _scorer.preview(
    ContestQso(
      id: excludeId ?? 'preview',
      call: call,
      time: UtcDateTime.now(),
      band: band,
      mode: mode,
      me: spec.me,
      them: themFor(call, rcvd),
      rcvd: rcvd,
    ),
  );

  /// Earlier contacts with [call], for the dupe hint.
  DupeResult dupeCheck({
    required String call,
    required Band band,
    required Mode mode,
  }) => _dupes.check(call: call, band: band, mode: mode);
}

/// An immutable view of the engine after one update. A new instance is
/// published whenever the engine changed, so widgets rebuild exactly then.
@immutable
class ContestLive {
  /// Wraps [engine] at its current [ContestEngine.version].
  new(this.engine) : version = engine.version, score = engine.score;

  /// The engine (read-only for widgets).
  final ContestEngine engine;

  /// The engine version this snapshot was taken at.
  final int version;

  /// The score at that version.
  final ContestScore score;

  /// The QSOs, oldest first.
  List<Qso> get qsos => engine.qsos;
}
