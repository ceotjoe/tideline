import 'package:meta/meta.dart';
import 'package:tideline_domain/src/contest/contest_definition.dart';
import 'package:tideline_domain/src/contest/contest_station.dart';
import 'package:tideline_domain/src/contest/exchange.dart';
import 'package:tideline_domain/src/contest/mode_category.dart';
import 'package:tideline_domain/src/contest/wpx_prefix.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/mode.dart';
import 'package:tideline_domain/src/values/utc_date_time.dart';

/// A QSO as the scorer sees it. The caller resolves DXCC entity and
/// continent of both stations (the received exchange taking precedence over
/// the resolver where it carries a zone or entity).
@immutable
final class ContestQso {
  /// Creates a scoring input.
  const new({
    required this.id,
    required this.call,
    required this.time,
    required this.band,
    required this.mode,
    required this.me,
    required this.them,
    this.rcvd = const {},
  });

  /// The QSO id.
  final String id;

  /// Their callsign (upper case).
  final String call;

  /// Start of the contact.
  final UtcDateTime time;

  /// The band.
  final Band band;

  /// The mode.
  final Mode mode;

  /// My station.
  final ContestStation me;

  /// Their station.
  final ContestStation them;

  /// The received exchange values by element kind (normalised).
  final Map<ExchangeKind, String> rcvd;
}

/// Whether a QSO counts.
enum QsoScoreStatus {
  /// Counts.
  valid,

  /// An earlier QSO has the same call and dupe slot; scores nothing.
  dupe,

  /// Band or mode category is not part of the contest; scores nothing.
  outOfContest,
}

/// One multiplier value credited by a QSO.
@immutable
final class MultiplierHit {
  /// Creates a hit.
  const new({
    required this.multiplierId,
    required this.value,
    this.scopeKey = '',
  });

  /// The multiplier rule's id.
  final String multiplierId;

  /// The value, e.g. a zone or prefix.
  final String value;

  /// The scope it counts in: a band name, `band|CATEGORY` or empty.
  final String scopeKey;
}

/// The score of one QSO.
@immutable
final class QsoScore {
  /// Creates a QSO score.
  const new({
    required this.id,
    required this.status,
    required this.points,
    this.newMultipliers = const [],
  });

  /// The QSO id.
  final String id;

  /// Whether it counts.
  final QsoScoreStatus status;

  /// Points (0 unless valid).
  final int points;

  /// Multiplier values this QSO credited first.
  final List<MultiplierHit> newMultipliers;

  /// Whether it is a dupe.
  bool get isDupe => status == QsoScoreStatus.dupe;

  /// Whether it credits at least one multiplier.
  bool get isNewMultiplier => newMultipliers.isNotEmpty;
}

/// Totals of one band.
@immutable
final class BandScore {
  /// Creates the totals.
  const new({
    required this.band,
    required this.qsos,
    required this.points,
    required this.multipliers,
  });

  /// The band.
  final Band band;

  /// Valid QSOs.
  final int qsos;

  /// Points.
  final int points;

  /// Multiplier values credited by QSOs on this band (a contest-wide
  /// multiplier is attributed to the band of its first QSO).
  final int multipliers;
}

/// The running totals.
@immutable
final class ContestScore {
  /// Creates a score.
  const new({
    required this.qsos,
    required this.dupes,
    required this.outOfContest,
    required this.points,
    required this.multipliers,
    required this.multipliersById,
    required this.total,
    required this.bands,
  });

  /// Valid QSOs.
  final int qsos;

  /// Dupes.
  final int dupes;

  /// QSOs outside the contest's bands or modes.
  final int outOfContest;

  /// Sum of points.
  final int points;

  /// Total multiplier count (all rules, all scopes).
  final int multipliers;

  /// Multiplier count by rule id.
  final Map<String, int> multipliersById;

  /// The claimed score (an estimate; the sponsor's log check decides).
  final int total;

  /// Per-band breakdown, lowest band first.
  final List<BandScore> bands;
}

/// Result of [ContestScorer.scoreAll].
@immutable
final class ContestScoreReport {
  /// Creates a report.
  const new({required this.score, required this.perQso});

  /// The totals.
  final ContestScore score;

  /// One entry per input QSO, in chronological order.
  final List<QsoScore> perQso;
}

class _BandAcc {
  int qsos = 0;
  int points = 0;
  int multipliers = 0;
}

/// Scores a contest log, incrementally.
///
/// Add QSOs in chronological order with [add]; the first QSO with a given
/// call and dupe slot is valid, later ones are dupes. For edits and deletes,
/// build a new scorer ([scoreAll] sorts for you). The score is an estimate.
final class ContestScorer {
  /// Creates an empty scorer.
  new(this.definition);

  /// Scores [qsos] chronologically (stable for equal times).
  static ContestScoreReport scoreAll(
    ContestDefinition definition,
    Iterable<ContestQso> qsos,
  ) {
    final indexed = qsos.toList();
    final order = List<int>.generate(indexed.length, (i) => i)
      ..sort((a, b) {
        final c = indexed[a].time.compareTo(indexed[b].time);
        return c != 0 ? c : a.compareTo(b);
      });
    final scorer = ContestScorer(definition);
    final perQso = [for (final i in order) scorer.add(indexed[i])];
    return ContestScoreReport(score: scorer.score, perQso: perQso);
  }

  /// The definition being scored.
  final ContestDefinition definition;

  final Set<String> _dupeKeys = {};
  final Set<String> _multKeys = {};
  final Map<String, int> _multCounts = {};
  final Map<Band, _BandAcc> _bands = {};
  int _qsos = 0;
  int _dupes = 0;
  int _outOfContest = 0;
  int _points = 0;
  int _multipliers = 0;

  /// Scores [qso] as if it were added next, without changing the state: for
  /// the "new multiplier / dupe" hint before saving.
  QsoScore preview(ContestQso qso) => _evaluate(qso, commit: false);

  /// Scores [qso] and adds it.
  QsoScore add(ContestQso qso) => _evaluate(qso, commit: true);

  /// The totals so far.
  ContestScore get score {
    final bands = [
      for (final band in Band.all)
        if (_bands[band] case final acc?)
          BandScore(
            band: band,
            qsos: acc.qsos,
            points: acc.points,
            multipliers: acc.multipliers,
          ),
    ];
    final total = switch (definition.score) {
      ScoreKind.pointsTimesMultipliers => _points * _multipliers,
      ScoreKind.points => _points,
      ScoreKind.qsos => _qsos,
    };
    return ContestScore(
      qsos: _qsos,
      dupes: _dupes,
      outOfContest: _outOfContest,
      points: _points,
      multipliers: _multipliers,
      multipliersById: Map.unmodifiable(_multCounts),
      total: total,
      bands: bands,
    );
  }

  QsoScore _evaluate(ContestQso qso, {required bool commit}) {
    final category = ModeCategory.of(qso.mode);
    if (!definition.allowsBand(qso.band) ||
        !definition.allowsCategory(category)) {
      if (commit) _outOfContest++;
      return QsoScore(
        id: qso.id,
        status: QsoScoreStatus.outOfContest,
        points: 0,
      );
    }
    final dupeKey =
        '${qso.call.trim().toUpperCase()}|'
        '${definition.dupe.slotKey(qso.band, qso.mode)}';
    if (_dupeKeys.contains(dupeKey)) {
      if (commit) _dupes++;
      return QsoScore(id: qso.id, status: QsoScoreStatus.dupe, points: 0);
    }

    var points = 0;
    if (definition.score == ScoreKind.qsos) {
      points = 1;
    } else {
      for (final rule in definition.points) {
        if (rule.when == null ||
            rule.when!.matches(
              me: qso.me,
              them: qso.them,
              qsoBand: qso.band,
              category: category,
            )) {
          points = rule.points;
          break;
        }
      }
    }

    final hits = <MultiplierHit>[];
    final newKeys = <String>[];
    for (var i = 0; i < definition.multipliers.length; i++) {
      final rule = definition.multipliers[i];
      final when = rule.when;
      if (when != null &&
          !when.matches(
            me: qso.me,
            them: qso.them,
            qsoBand: qso.band,
            category: category,
          )) {
        continue;
      }
      final value = _valueOf(rule.source, qso);
      if (value == null) continue;
      final scope = switch (rule.per) {
        MultiplierScope.band => qso.band.name,
        MultiplierScope.bandMode => '${qso.band.name}|${category.jsonName}',
        MultiplierScope.contest => '',
      };
      final key = '$i|$scope|$value';
      if (_multKeys.contains(key) || newKeys.contains(key)) continue;
      newKeys.add(key);
      hits.add(
        MultiplierHit(multiplierId: rule.id, value: value, scopeKey: scope),
      );
    }

    if (commit) {
      _dupeKeys.add(dupeKey);
      _multKeys.addAll(newKeys);
      _qsos++;
      _points += points;
      _multipliers += hits.length;
      for (final hit in hits) {
        _multCounts.update(hit.multiplierId, (n) => n + 1, ifAbsent: () => 1);
      }
      _bands.putIfAbsent(qso.band, _BandAcc.new)
        ..qsos += 1
        ..points += points
        ..multipliers += hits.length;
    }
    return QsoScore(
      id: qso.id,
      status: QsoScoreStatus.valid,
      points: points,
      newMultipliers: List.unmodifiable(hits),
    );
  }

  static String? _valueOf(MultiplierSource source, ContestQso qso) {
    switch (source.kind) {
      case MultiplierSourceKind.dxcc:
        return qso.them.dxcc?.toString();
      case MultiplierSourceKind.wpxPrefix:
        return WpxPrefix.of(qso.call);
      case MultiplierSourceKind.continent:
        return qso.them.continent;
      case MultiplierSourceKind.grid4:
        final grid = qso.rcvd[ExchangeKind.grid]?.trim().toUpperCase();
        return grid != null && grid.length >= 4 ? grid.substring(0, 4) : null;
      case MultiplierSourceKind.rcvd:
        final kind = source.element!;
        final raw = qso.rcvd[kind];
        if (raw == null) return null;
        final value = kind.parse(raw).value;
        return value;
    }
  }
}
