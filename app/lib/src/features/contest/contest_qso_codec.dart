import 'package:flutter/foundation.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Which part of the entry a [ContestIssue] belongs to.
enum ContestIssueField {
  /// The callsign.
  call,

  /// A received exchange element, see [ContestIssue.elementIndex].
  element,

  /// The band.
  band,

  /// The mode.
  mode,

  /// The frequency text.
  frequency,
}

/// A problem found when validating an entry. The UI turns it into a
/// localised message; this layer only knows the typed cause.
@immutable
class ContestIssue {
  /// Creates an issue.
  const new(
    this.field, {
    this.elementIndex,
    this.error,
    this.outsideBand = false,
  });

  /// The offending part.
  final ContestIssueField field;

  /// The received-exchange index for [ContestIssueField.element].
  final int? elementIndex;

  /// Why the element was rejected.
  final ExchangeError? error;

  /// For [ContestIssueField.frequency]: parsed, but not inside the band.
  final bool outsideBand;

  @override
  bool operator ==(Object other) =>
      other is ContestIssue &&
      other.field == field &&
      other.elementIndex == elementIndex &&
      other.error == error &&
      other.outsideBand == outsideBand;

  @override
  int get hashCode => Object.hash(field, elementIndex, error, outsideBand);
}

/// A fully validated entry, normalised (upper-case, no leading zeros).
@immutable
class ValidContestEntry {
  /// Creates the entry.
  const new({
    required this.call,
    required this.band,
    required this.mode,
    required this.freqHz,
    required this.rcvd,
  });

  /// The callsign.
  final Callsign call;

  /// The band.
  final Band band;

  /// The mode.
  final Mode mode;

  /// The frequency in Hz, if one was typed.
  final int? freqHz;

  /// Received exchange values aligned with the exchange elements; optional
  /// elements left empty are empty strings.
  final List<String> rcvd;
}

/// Result of [validateContestEntry]: either [entry] or [issues], listed in
/// focus order (call, exchange elements in order, band, mode, frequency).
@immutable
class ContestValidation {
  /// Creates a result.
  const new({this.entry, this.issues = const []});

  /// The valid entry, null if there are [issues].
  final ValidContestEntry? entry;

  /// Problems, in the order they should receive focus.
  final List<ContestIssue> issues;
}

/// Checks an entry against the exchange of [spec]. Pure and synchronous.
///
/// An empty received report is filled with the default for the mode
/// (59 or 599), because operators rarely type it.
ContestValidation validateContestEntry({
  required ContestSpec spec,
  required String call,
  required Band? band,
  required Mode? mode,
  required String frequency,
  required List<String> rcvd,
}) {
  final issues = <ContestIssue>[];
  final parsedCall = Callsign.tryParse(call);
  if (parsedCall == null) {
    issues.add(const ContestIssue(ContestIssueField.call));
  }

  final category = mode == null ? null : ModeCategory.of(mode);
  final values = <String>[];
  for (final (i, element) in spec.exchange.rcvd.indexed) {
    var raw = i < rcvd.length ? rcvd[i] : '';
    if (element.kind == ExchangeKind.rst && raw.trim().isEmpty) {
      raw = element.defaultFor(spec.me, category: category) ?? '';
    }
    final result = element.check(raw);
    if (result.error != null) {
      issues.add(
        ContestIssue(
          ContestIssueField.element,
          elementIndex: i,
          error: result.error,
        ),
      );
    }
    values.add(result.value ?? '');
  }

  int? freqHz;
  final text = frequency.trim();
  final reading = text.isEmpty ? null : Frequency.interpretUserInput(text);
  final effectiveBand = band ?? reading?.band;
  if (effectiveBand == null) {
    issues.add(const ContestIssue(ContestIssueField.band));
  }
  if (mode == null) issues.add(const ContestIssue(ContestIssueField.mode));
  if (text.isNotEmpty) {
    if (reading == null) {
      issues.add(const ContestIssue(ContestIssueField.frequency));
    } else if (effectiveBand != null && !effectiveBand.contains(reading.hz)) {
      issues.add(
        const ContestIssue(ContestIssueField.frequency, outsideBand: true),
      );
    } else {
      freqHz = reading.hz;
    }
  }

  if (issues.isNotEmpty) return ContestValidation(issues: issues);
  return ContestValidation(
    entry: ValidContestEntry(
      call: parsedCall!,
      band: effectiveBand!,
      mode: mode!,
      freqHz: freqHz,
      rcvd: values,
    ),
  );
}

/// ADIF fields describing the contacted entity, from the offline resolver.
Map<String, String> dxccFieldsFor(String call, DxccDatabase? dxcc) {
  final match = dxcc?.resolve(call);
  if (match == null) return const {};
  return {
    'DXCC': '${match.entity.dxcc}',
    'COUNTRY': match.entity.name,
    'CQZ': '${match.cqz}',
    'ITUZ': '${match.ituz}',
    'CONT': match.continent,
  };
}

/// Builds the QSO for a validated entry. The sent serial is not set here:
/// it is allocated inside the database transaction, see
/// [contestSerialFields].
Qso buildContestQso({
  required ContestSpec spec,
  required ValidContestEntry entry,
  required String accountId,
  required String? stationProfileId,
  DxccDatabase? dxcc,
  UtcDateTime? at,
}) {
  final category = ModeCategory.of(entry.mode);
  final sent = ExchangeMapping.toAdif(
    ExchangeSide.sent,
    spec.exchange.sent,
    spec.sentValues(category: category),
  );
  final rcvd = ExchangeMapping.toAdif(
    ExchangeSide.rcvd,
    spec.exchange.rcvd,
    entry.rcvd,
  );
  return Qso(
    id: newUuidV4(),
    accountId: accountId,
    stationProfileId: stationProfileId,
    call: entry.call,
    timeOn: at ?? UtcDateTime.now(),
    band: entry.band,
    mode: entry.mode,
    freqHz: entry.freqHz,
    rstSent: sent.rst ?? entry.mode.defaultReport,
    rstRcvd: rcvd.rst ?? entry.mode.defaultReport,
    fields: {
      ...dxccFieldsFor(entry.call.value, dxcc),
      ...rcvd.fields,
      ...sent.fields,
    },
  );
}

/// The ADIF fields that depend on the allocated serial (`STX`, and the
/// joined exchange string when the exchange has no string element).
Map<String, String> Function(int serial) contestSerialFields({
  required ContestSpec spec,
  required ModeCategory category,
}) =>
    (serial) => ExchangeMapping.toAdif(
      ExchangeSide.sent,
      spec.exchange.sent,
      spec.sentValues(category: category, serial: serial),
    ).fields;

/// Applies an edited, validated entry to [original]. The sent exchange
/// (including the serial) is never touched.
Qso applyContestEdit({
  required ContestSpec spec,
  required Qso original,
  required ValidContestEntry entry,
  DxccDatabase? dxcc,
}) {
  final rcvd = ExchangeMapping.toAdif(
    ExchangeSide.rcvd,
    spec.exchange.rcvd,
    entry.rcvd,
  );
  final dropped = <String>{
    ExchangeKind.srxString,
    'DXCC',
    'COUNTRY',
    'CQZ',
    'ITUZ',
    'CONT',
    for (final e in spec.exchange.rcvd) e.kind.rcvdField,
  };
  final fields = {
    for (final e in original.fields.entries)
      if (!dropped.contains(e.key)) e.key: e.value,
    ...dxccFieldsFor(entry.call.value, dxcc),
    ...rcvd.fields,
  };
  final keepFrequency =
      entry.band == original.band ||
      (original.freqHz != null && entry.band.contains(original.freqHz!));
  return Qso(
    id: original.id,
    accountId: original.accountId,
    stationProfileId: original.stationProfileId,
    call: entry.call,
    timeOn: original.timeOn,
    timeOff: original.timeOff,
    band: entry.band,
    bandRx: original.bandRx,
    mode: entry.mode,
    freqHz: keepFrequency ? original.freqHz : null,
    freqRxHz: original.freqRxHz,
    rstSent: original.rstSent,
    rstRcvd: rcvd.rst ?? original.rstRcvd,
    fields: fields,
    source: original.source,
    contestSessionId: original.contestSessionId,
    activationId: original.activationId,
  );
}

/// The received exchange values stored on [qso], aligned with the received
/// elements of [spec].
List<String> rcvdValuesOf(ContestSpec spec, Qso qso) =>
    ExchangeMapping.fromAdif(
      ExchangeSide.rcvd,
      spec.exchange.rcvd,
      rst: qso.rstRcvd,
      fields: qso.fields,
    );

/// The sent exchange values stored on [qso], aligned with the sent elements
/// of [spec]. The serial comes from the stored `STX`.
List<String> sentValuesOf(ContestSpec spec, Qso qso) =>
    ExchangeMapping.fromAdif(
      ExchangeSide.sent,
      spec.exchange.sent,
      rst: qso.rstSent,
      fields: qso.fields,
    );
