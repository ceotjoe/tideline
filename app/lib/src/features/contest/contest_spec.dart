import 'package:flutter/foundation.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The station that operates a contest: callsign, DXCC data from the
/// offline resolver, the station profile's locator and the state or DOK the
/// operator entered in the session setup.
ContestStation contestStationFor({
  required String call,
  DxccDatabase? dxcc,
  String? grid,
  Map<String, String> ownExchange = const {},
}) {
  final match = call.isEmpty ? null : dxcc?.resolve(call);
  final base = ContestStation.fromMatch(call, match);
  return ContestStation(
    call: base.call,
    dxcc: base.dxcc,
    continent: base.continent,
    cqz: base.cqz,
    ituz: base.ituz,
    grid: grid == null || grid.isEmpty ? null : grid.toUpperCase(),
    state: ownExchange[ExchangeKind.state.name],
    dok: ownExchange[ExchangeKind.dok.name],
  );
}

/// The key under which the value of `sent[index]` is stored in
/// [ContestSession.ownExchange]: the kind name, with `#n` for a repeated
/// kind (two `text` elements, for example).
String ownExchangeKey(List<ExchangeElement> sent, int index) {
  final kind = sent[index].kind;
  final before = sent.take(index).where((e) => e.kind == kind).length;
  return before == 0 ? kind.name : '${kind.name}#$before';
}

/// The mode category a session starts in: the first one the contest allows.
ModeCategory firstCategory(ContestDefinition definition) =>
    definition.modes.first;

/// A sensible starting mode for [category].
Mode defaultModeFor(ModeCategory category) => Mode.tryParse(switch (category) {
  ModeCategory.cw => 'CW',
  ModeCategory.phone => 'SSB',
  ModeCategory.digi => 'RTTY',
})!;

/// Modes the entry offers for [definition]: the common modes in the
/// contest's categories.
List<Mode> contestModes(ContestDefinition definition) => [
  for (final m in Mode.common)
    if (definition.allowsCategory(ModeCategory.of(m))) m,
];

/// Bands the entry offers for [definition], in frequency order.
List<Band> contestBands(ContestDefinition definition) => [
  for (final b in Band.all)
    if (definition.allowsBand(b)) b,
];

/// Everything the contest screens need to know about the running session,
/// resolved once: the definition, my station and the exchange that applies
/// to me. Two specs are equal when nothing the screens depend on changed,
/// so sync updates to the session row never rebuild the scoring.
@immutable
class ContestSpec {
  /// Creates the spec.
  const new({
    required this.session,
    required this.definition,
    required this.me,
    required this.exchange,
  });

  /// The stored session.
  final ContestSession session;

  /// The rules.
  final ContestDefinition definition;

  /// My station.
  final ContestStation me;

  /// The exchange for [me] (a variant may apply).
  final ResolvedExchange exchange;

  /// Whether sent serials are allocated.
  bool get usesSerial =>
      exchange.sent.any((e) => e.kind == ExchangeKind.serial);

  /// The values of my sent exchange, aligned with [ResolvedExchange.sent].
  ///
  /// The serial is [serial] (null shows an empty slot); the report is the
  /// default of [category].
  List<String> sentValues({ModeCategory? category, int? serial}) => [
    for (final (i, e) in exchange.sent.indexed)
      switch (e.kind) {
        ExchangeKind.serial => serial?.toString() ?? '',
        ExchangeKind.rst => e.defaultFor(me, category: category) ?? '',
        _ =>
          session.ownExchange[ownExchangeKey(exchange.sent, i)] ??
              e.defaultFor(me, category: category) ??
              '',
      },
  ];

  @override
  bool operator ==(Object other) =>
      other is ContestSpec &&
      other.session.id == session.id &&
      other.session.accountId == session.accountId &&
      other.session.stationProfileId == session.stationProfileId &&
      mapEquals(other.session.ownExchange, session.ownExchange) &&
      other.definition == definition &&
      other.me.call == me.call &&
      other.me.dxcc == me.dxcc &&
      other.me.cqz == me.cqz &&
      other.me.grid == me.grid;

  @override
  int get hashCode => Object.hash(
    session.id,
    session.stationProfileId,
    definition,
    me.call,
    me.dxcc,
    me.grid,
  );
}
