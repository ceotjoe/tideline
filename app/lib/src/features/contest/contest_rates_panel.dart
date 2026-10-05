import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/contest/contest_engine.dart';
import 'package:tideline/src/features/contest/contest_labels.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/log/qso_tile.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/widgets/frequency_field.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// How often the time-based rates are recomputed while the panel is
/// visible. Rates are per hour, so a few seconds is plenty.
const Duration ratesTick = Duration(seconds: 5);

/// The same with the battery saver on (ADR 0029).
const Duration ratesTickSaver = Duration(seconds: 30);

/// The rates derived from QSO times at one moment.
@immutable
class ContestRateSnapshot {
  /// Computes the snapshot of [times] at [now].
  new of(List<UtcDateTime> times, UtcDateTime now)
    : last10Minutes = ContestRates.last10MinutesRate(times, now),
      last60Minutes = ContestRates.last60MinutesRate(times, now),
      last10Qsos = ContestRates.rateOverLast10(times, now),
      last100Qsos = ContestRates.rateOverLast100(times, now),
      best = ContestRates.bestWindow(times, now);

  /// QSOs per hour over the last 10 minutes.
  final double last10Minutes;

  /// QSOs per hour over the last 60 minutes.
  final double last60Minutes;

  /// QSOs per hour over the last 10 QSOs, null with fewer.
  final double? last10Qsos;

  /// QSOs per hour over the last 100 QSOs, null with fewer.
  final double? last100Qsos;

  /// The busiest 60 minutes so far.
  final BestWindow? best;
}

/// QSO count, points, multipliers, the claimed score (an estimate), the
/// per-band table and the rates.
///
/// Updates when a QSO arrives and on a slow ticker. The ticker stops while
/// the panel is not visible (route covered, panel collapsed, app in the
/// background), and numbers change without animation under reduce-motion.
class ContestRatesPanel extends ConsumerStatefulWidget {
  /// Creates the panel. [showTitle] is false where a header above it
  /// already names it.
  const new({this.showTitle = true, super.key});

  /// Whether to show the "Score and rates" heading.
  final bool showTitle;

  /// How many rate tickers are running right now. Tests use it to check
  /// that a hidden panel does not keep a timer alive.
  @visibleForTesting
  static int activeTickers = 0;

  @override
  ConsumerState<ContestRatesPanel> createState() => _ContestRatesPanelState();
}

class _ContestRatesPanelState extends ConsumerState<ContestRatesPanel>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _foreground = true;
  bool _tickerEnabled = true;
  UtcDateTime _now = UtcDateTime.now();
  ContestRateSnapshot? _rates;
  int? _ratesVersion;
  ContestEngine? _ratesEngine;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
    _updateTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) _refresh();
    _updateTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    ContestRatesPanel.activeTickers--;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timer != null) _stopTimer();
    super.dispose();
  }

  void _updateTimer() {
    final shouldRun = _foreground && _tickerEnabled;
    if (shouldRun && _timer == null) {
      _timer = Timer.periodic(
        (ref.read(appSettingsProvider).value?.batterySaver ?? false)
            ? ratesTickSaver
            : ratesTick,
        (_) => _refresh(),
      );
      ContestRatesPanel.activeTickers++;
    } else if (!shouldRun && _timer != null) {
      _stopTimer();
    }
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _now = UtcDateTime.now();
      _ratesVersion = null;
    });
  }

  ContestRateSnapshot _ratesFor(ContestLive live) {
    if (_rates == null ||
        _ratesVersion != live.version ||
        !identical(_ratesEngine, live.engine)) {
      _now = UtcDateTime.now();
      _rates = ContestRateSnapshot.of(live.engine.times, _now);
      _ratesVersion = live.version;
      _ratesEngine = live.engine;
    }
    return _rates!;
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(contestLiveProvider);
    final spec = ref.watch(contestSpecProvider);
    if (live == null || spec == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final text = Theme.of(context).textTheme;
    final score = live.score;
    final rates = _ratesFor(live);
    final duration = TidelineMetrics.motion(
      context,
      TidelineMetrics.durationShort,
    );

    Widget metric(String label, String value) => Semantics(
      container: true,
      label: l10n.contestLabelValue(label, value),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodySmall),
          AnimatedSwitcher(
            duration: duration,
            child: Text(value, key: ValueKey(value), style: text.titleLarge),
          ),
        ],
      ),
    );

    String rate(double? perHour) =>
        perHour == null ? '–' : l10n.contestRatePerHour(perHour.round());

    final multiplierLines = [
      for (final m in spec.definition.multipliers)
        '${multiplierLabel(l10n, m.id)} ${score.multipliersById[m.id] ?? 0}',
    ];

    return Padding(
      padding: EdgeInsets.all(metrics.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showTitle) ...[
            Semantics(
              header: true,
              child: Text(l10n.contestPanelTitle, style: text.titleMedium),
            ),
            SizedBox(height: metrics.sm),
          ],
          Wrap(
            spacing: metrics.lg,
            runSpacing: metrics.sm,
            children: [
              metric(l10n.contestQsos, '${score.qsos}'),
              metric(l10n.contestPointsLabel, '${score.points}'),
              if (spec.definition.multipliers.isNotEmpty)
                metric(l10n.contestMultipliers, '${score.multipliers}'),
              if (score.dupes > 0) metric(l10n.contestDupes, '${score.dupes}'),
            ],
          ),
          if (multiplierLines.isNotEmpty) ...[
            SizedBox(height: metrics.xs),
            Text(multiplierLines.join(' · '), style: text.bodySmall),
          ],
          SizedBox(height: metrics.sm),
          Container(
            padding: EdgeInsets.all(metrics.sm),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
            ),
            child: Semantics(
              container: true,
              label:
                  '${l10n.contestScoreEstimate}: ${score.total}. '
                  '${l10n.contestScoreEstimateNote}',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.contestScoreEstimate, style: text.bodySmall),
                  AnimatedSwitcher(
                    duration: duration,
                    child: Text(
                      '${score.total}',
                      key: ValueKey(score.total),
                      style: text.displayLarge,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      SizedBox(width: metrics.xs),
                      Expanded(
                        child: Text(
                          l10n.contestScoreEstimateNote,
                          style: text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: metrics.md),
          Semantics(
            header: true,
            child: Text(l10n.contestRatesTitle, style: text.titleMedium),
          ),
          SizedBox(height: metrics.xs),
          _KeyValue(l10n.contestRate10Min, rate(rates.last10Minutes)),
          _KeyValue(l10n.contestRate60Min, rate(rates.last60Minutes)),
          _KeyValue(l10n.contestRateLast10, rate(rates.last10Qsos)),
          _KeyValue(l10n.contestRateLast100, rate(rates.last100Qsos)),
          _KeyValue(
            l10n.contestRateBest,
            rates.best == null
                ? '–'
                : l10n.contestRateBestValue(
                    rates.best!.count,
                    utcClock(rates.best!.start),
                    l10n.unitUtc,
                  ),
          ),
          SizedBox(height: metrics.md),
          Semantics(
            header: true,
            child: Text(l10n.contestBandsTitle, style: text.titleMedium),
          ),
          SizedBox(height: metrics.xs),
          if (score.bands.isEmpty)
            Text(l10n.contestBandsEmpty, style: text.bodyMedium)
          else
            _BandTable(score: score),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const new(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l10n.contestLabelValue(label, value),
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.metrics.xs / 2),
        child: Row(
          children: [
            Expanded(child: Text(label, style: text.bodyMedium)),
            SizedBox(width: context.metrics.sm),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: text.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BandTable extends StatelessWidget {
  const new({required this.score});

  final ContestScore score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final metrics = context.metrics;
    Widget cell(String value, {bool header = false, bool end = true}) =>
        Padding(
          padding: EdgeInsets.symmetric(vertical: metrics.xs / 2),
          child: Text(
            value,
            textAlign: end ? TextAlign.end : TextAlign.start,
            style: header ? text.bodySmall : text.bodyMedium,
          ),
        );
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.4)},
      children: [
        TableRow(
          children: [
            cell(l10n.fieldBand, header: true, end: false),
            cell(l10n.contestQsos, header: true),
            cell(l10n.contestPointsLabel, header: true),
            cell(l10n.contestMultipliers, header: true),
          ],
        ),
        for (final b in score.bands)
          TableRow(
            children: [
              cell(bandDisplayName(b.band), end: false),
              cell('${b.qsos}'),
              cell('${b.points}'),
              cell('${b.multipliers}'),
            ],
          ),
      ],
    );
  }
}
