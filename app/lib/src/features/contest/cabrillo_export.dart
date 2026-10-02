import 'dart:convert';

import 'package:tideline/src/app_version.dart';
import 'package:tideline/src/features/contest/cabrillo_categories.dart';
import 'package:tideline/src/features/contest/contest_qso_codec.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A Cabrillo log ready to be shown, checked and saved.
class CabrilloExport {
  /// Creates the export.
  const new({
    required this.header,
    required this.qsos,
    required this.issues,
    required this.fileName,
  });

  /// The header lines.
  final CabrilloHeader header;

  /// The QSO lines, oldest first.
  final List<CabrilloQso> qsos;

  /// What [CabrilloWriter.validate] found; empty if the log is clean.
  final List<CabrilloIssue> issues;

  /// The suggested file name, for example `DO1HOZ-DARC-WAG-2026.log`.
  final String fileName;

  /// The log text (ASCII, CRLF line ends).
  String get text => const CabrilloWriter().write(header, qsos);

  /// [text] as bytes. ASCII is a subset of UTF-8, so this is both.
  List<int> get bytes => utf8.encode(text);
}

/// The Cabrillo mode column for [mode]: CW, PH (all voice but FM), FM, RY
/// (RTTY) and DG (every other digital mode).
CabrilloMode cabrilloModeOf(Mode mode) => switch (mode.mode) {
  'FM' => CabrilloMode.fm,
  'RTTY' => CabrilloMode.rtty,
  _ => switch (ModeCategory.of(mode)) {
    ModeCategory.cw => CabrilloMode.cw,
    ModeCategory.phone => CabrilloMode.phone,
    ModeCategory.digi => CabrilloMode.digi,
  },
};

/// The exchange tokens of one side, one per logical column.
///
/// Consecutive elements with a `when` are per-station alternatives (WAG:
/// serial for foreign stations, DOK for German ones). They share one
/// column, which holds whichever alternative has a value. Every other
/// element is a column of its own, so all lines have the same number of
/// tokens. Tokens come from [ExchangeMapping.cabrilloTokens].
List<String> cabrilloColumns(
  List<ExchangeElement> elements,
  List<String> values,
) {
  if (elements.length != values.length) {
    throw ArgumentError.value(values, 'values', 'length differs');
  }
  final columns = <String>[];
  var i = 0;
  while (i < elements.length) {
    var end = i + 1;
    if (elements[i].when != null) {
      while (end < elements.length && elements[end].when != null) {
        end++;
      }
    }
    final tokens = ExchangeMapping.cabrilloTokens(
      elements.sublist(i, end),
      values.sublist(i, end),
    );
    columns.add(tokens.where((t) => t.isNotEmpty).firstOrNull ?? '');
    i = end;
  }
  return columns;
}

/// The suggested file name: `<CALL>-<cabrillo>-<year>.log`. Characters
/// that are unsafe in file names (such as the `/` in `DL/DO1HOZ`) become
/// `-`.
String cabrilloFileName({
  required String callsign,
  required String contest,
  required int year,
}) {
  String safe(String s) => s.replaceAll(RegExp('[^A-Za-z0-9._-]+'), '-');
  return '${safe(callsign.toUpperCase())}-${safe(contest)}-$year.log';
}

/// Builds the Cabrillo log of a contest session.
///
/// [spec] describes the session, its definition and my station; [qsos] are
/// the session's QSOs, oldest first; [claimedScore] comes from the contest
/// engine. Returns null if the definition has no Cabrillo name, because
/// then no export is offered.
CabrilloExport? buildCabrilloExport({
  required ContestSpec spec,
  required List<Qso> qsos,
  required int claimedScore,
  required String callsign,
  String? gridLocator,
  String version = appVersion,
}) {
  final contest = spec.definition.cabrillo;
  if (contest == null) return null;
  final session = spec.session;
  String? tag(CabrilloCategory c) => session.cabrillo[c.tag];

  // LOCATION is the section the operator entered for contests that ask for
  // one, unless the session stored it explicitly.
  final location =
      session.cabrillo['LOCATION'] ??
      session.ownExchange[ExchangeKind.section.name];

  final header = CabrilloHeader(
    contest: contest,
    callsign: callsign,
    createdBy: 'Tideline $version',
    location: location,
    categoryOperator: tag(CabrilloCategory.operator),
    categoryAssisted: tag(CabrilloCategory.assisted),
    categoryBand: tag(CabrilloCategory.band),
    categoryMode: tag(CabrilloCategory.mode),
    categoryPower: tag(CabrilloCategory.power),
    categoryStation: tag(CabrilloCategory.station),
    categoryTransmitter: tag(CabrilloCategory.transmitter),
    categoryOverlay: tag(CabrilloCategory.overlay),
    categoryTime: tag(CabrilloCategory.time),
    claimedScore: claimedScore,
    gridLocator: gridLocator,
    operators: callsign,
  );

  final lines = [
    for (final q in qsos)
      CabrilloQso(
        frequencyHz: q.freqHz ?? 0,
        band: q.band.name,
        mode: cabrilloModeOf(q.mode),
        time: q.timeOn,
        myCall: callsign,
        sentExchange: cabrilloColumns(
          spec.exchange.sent,
          sentValuesOf(spec, q),
        ),
        theirCall: q.call.value,
        receivedExchange: cabrilloColumns(
          spec.exchange.rcvd,
          rcvdValuesOf(spec, q),
        ),
      ),
  ];

  return CabrilloExport(
    header: header,
    qsos: lines,
    issues: const CabrilloWriter().validate(header, lines),
    fileName: cabrilloFileName(
      callsign: callsign,
      contest: contest,
      year: UtcDateTime.fromMillis(session.startedAt).value.year,
    ),
  );
}
