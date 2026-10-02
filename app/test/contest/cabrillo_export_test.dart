import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/app_version.dart';
import 'package:tideline/src/features/contest/cabrillo_export.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';

/// A WAG session of a German station (DXCC 230): foreign stations send a
/// serial, German ones their DOK.
ContestSpec wagSpec({Map<String, String> cabrillo = const {}}) {
  final definition = bundledDefinition('darc-wag');
  const me = ContestStation(
    call: 'DO1HOZ',
    dxcc: 230,
    grid: 'JO40',
    dok: 'F03',
  );
  return ContestSpec(
    session: ContestSession(
      id: 's1',
      definitionId: definition.id,
      definitionVersion: 1,
      accountId: 'acc-1',
      startedAt: DateTime.utc(2026, 8, 22, 8).millisecondsSinceEpoch,
      ownExchange: const {'dok': 'F03'},
      cabrillo: cabrillo,
      usesSerial: false,
      remoteState: ContestRemoteState.local,
    ),
    definition: definition,
    me: me,
    exchange: definition.exchangeFor(me),
  );
}

/// A QSO stored the way the entry screen stores it.
Qso wagQso(
  ContestSpec spec,
  String call,
  int minute,
  List<String> rcvd, {
  String band = '20m',
  String mode = 'SSB',
  int? freqHz = 14250000,
}) {
  final sent = ExchangeMapping.toAdif(
    ExchangeSide.sent,
    spec.exchange.sent,
    spec.sentValues(category: ModeCategory.phone),
  );
  final received = ExchangeMapping.toAdif(
    ExchangeSide.rcvd,
    spec.exchange.rcvd,
    rcvd,
  );
  return Qso(
    id: 'q$minute',
    accountId: 'acc-1',
    call: Callsign.tryParse(call)!,
    timeOn: UtcDateTime(DateTime.utc(2026, 8, 22, 8, minute)),
    band: Band.tryParse(band)!,
    mode: Mode.tryParse(mode)!,
    freqHz: freqHz,
    rstSent: sent.rst,
    rstRcvd: received.rst,
    fields: {...sent.fields, ...received.fields},
  );
}

void main() {
  group('WAG with serial and DOK alternatives', () {
    final spec = wagSpec(
      cabrillo: const {
        'CATEGORY-OPERATOR': 'SINGLE-OP',
        'CATEGORY-POWER': 'LOW',
        'CATEGORY-TIME': '24-HOURS',
      },
    );
    // rcvd order: rst, serial (foreign), dok (German).
    final qsos = [
      wagQso(spec, 'DL1ABC', 0, ['59', '', 'A12']),
      wagQso(spec, 'G4XYZ', 1, ['57', '123', '']),
      wagQso(spec, 'DK2ZZ', 2, ['599', '', 'Z99'], mode: 'CW'),
      wagQso(spec, 'EA8ABC', 3, ['58', '7', '']),
    ];

    test('every line has the same number of columns', () {
      final export = buildCabrilloExport(
        spec: spec,
        qsos: qsos,
        claimedScore: 42,
        callsign: 'DO1HOZ',
        gridLocator: 'JO40',
      )!;
      expect(export.issues, isEmpty);
      final lines = export.qsos;
      expect({for (final q in lines) q.sentExchange.length}, {2});
      expect({for (final q in lines) q.receivedExchange.length}, {2});
      expect(lines[0].receivedExchange, ['59', 'A12']);
      expect(lines[1].receivedExchange, ['57', '123']);
      expect(lines[2].receivedExchange, ['599', 'Z99']);
      expect(lines[3].receivedExchange, ['58', '7']);
      expect(lines.first.sentExchange, ['59', 'F03']);

      final qsoLines = export.text
          .split('\r\n')
          .where((l) => l.startsWith('QSO:'))
          .toList();
      expect(qsoLines, hasLength(4));
      expect(
        {for (final l in qsoLines) l.split(RegExp(' +')).length},
        {11},
        reason: 'QSO: freq mode date time mycall rst dok theircall rst x',
      );
      List<String> tokens(String l) => l.split(RegExp(' +'));
      expect(tokens(qsoLines[0]).sublist(5), [
        'DO1HOZ', '59', 'F03', 'DL1ABC', '59', 'A12', //
      ]);
      expect(tokens(qsoLines[1]).sublist(5), [
        'DO1HOZ', '59', 'F03', 'G4XYZ', '57', '123', //
      ]);
    });

    test('header carries the station, categories, score and creator', () {
      final export = buildCabrilloExport(
        spec: spec,
        qsos: qsos,
        claimedScore: 42,
        callsign: 'DO1HOZ',
        gridLocator: 'jo40',
      )!;
      final text = export.text;
      expect(text, startsWith('START-OF-LOG: 3.0\r\n'));
      expect(text, contains('CREATED-BY: Tideline $appVersion\r\n'));
      expect(text, contains('CONTEST: DARC-WAG\r\n'));
      expect(text, contains('CALLSIGN: DO1HOZ\r\n'));
      expect(text, contains('OPERATORS: DO1HOZ\r\n'));
      expect(text, contains('GRID-LOCATOR: JO40\r\n'));
      expect(text, contains('CLAIMED-SCORE: 42\r\n'));
      expect(text, contains('CATEGORY-POWER: LOW\r\n'));
      expect(text, contains('CATEGORY-TIME: 24-HOURS\r\n'));
      expect(text, isNot(contains('CATEGORY-BAND')));
      expect(text, endsWith('END-OF-LOG:\r\n'));
    });

    test('modes map to the Cabrillo columns', () {
      final export = buildCabrilloExport(
        spec: spec,
        qsos: qsos,
        claimedScore: 0,
        callsign: 'DO1HOZ',
      )!;
      expect(export.qsos.map((q) => q.mode), [
        CabrilloMode.phone,
        CabrilloMode.phone,
        CabrilloMode.cw,
        CabrilloMode.phone,
      ]);
    });

    test('a QSO without frequency on an HF band is reported', () {
      final broken = wagQso(spec, 'DL9XX', 5, ['59', '', 'B1'], freqHz: null);
      final export = buildCabrilloExport(
        spec: spec,
        qsos: [broken],
        claimedScore: 0,
        callsign: 'DO1HOZ',
      )!;
      // HF lines need a frequency in kHz; the band alone is not enough.
      expect(export.issues.map((i) => i.kind), [
        CabrilloIssueKind.missingFrequency,
      ]);
      expect(export.issues.single.qsoIndex, 0);
    });
  });

  test('cabrilloColumns merges only adjacent alternatives', () {
    const rst = ExchangeElement(kind: ExchangeKind.rst);
    final serial = ExchangeElement(
      kind: ExchangeKind.serial,
      when: ContestPredicate.fromJson(const {'theirDxccNot': 230}, 'p'),
    );
    final dok = ExchangeElement(
      kind: ExchangeKind.dok,
      when: ContestPredicate.fromJson(const {'theirDxcc': 230}, 'p'),
    );
    expect(cabrilloColumns([rst, serial, dok], ['59', '', 'A1']), ['59', 'A1']);
    expect(cabrilloColumns([rst, serial, dok], ['59', '5', '']), ['59', '5']);
    // Nothing given for an alternative: an empty column keeps the layout.
    expect(cabrilloColumns([rst, serial, dok], ['59', '', '']), ['59', '']);
    // Without alternatives every element is a column.
    expect(
      cabrilloColumns(
        const [
          ExchangeElement(kind: ExchangeKind.rst),
          ExchangeElement(kind: ExchangeKind.cqZone),
        ],
        ['599', '14'],
      ),
      ['599', '14'],
    );
  });

  test('cabrilloModeOf follows the Cabrillo mode column', () {
    CabrilloMode of(String m) => cabrilloModeOf(Mode.tryParse(m)!);
    expect(of('CW'), CabrilloMode.cw);
    expect(of('USB'), CabrilloMode.phone);
    expect(of('AM'), CabrilloMode.phone);
    expect(of('FM'), CabrilloMode.fm);
    expect(of('RTTY'), CabrilloMode.rtty);
    expect(of('FT8'), CabrilloMode.digi);
  });

  test('file names are <CALL>-<cabrillo>-<year>.log with safe characters', () {
    expect(
      cabrilloFileName(callsign: 'do1hoz', contest: 'CQ-WW-SSB', year: 2026),
      'DO1HOZ-CQ-WW-SSB-2026.log',
    );
    expect(
      cabrilloFileName(
        callsign: 'DL/DO1HOZ/P',
        contest: 'DARC-WAG',
        year: 2026,
      ),
      'DL-DO1HOZ-P-DARC-WAG-2026.log',
    );
  });

  test('no Cabrillo name means no export', () {
    final definition = bundledDefinition('generic-serial');
    expect(definition.cabrillo, isNull);
    const me = ContestStation(call: 'DO1HOZ');
    final spec = ContestSpec(
      session: wagSpec().session,
      definition: definition,
      me: me,
      exchange: definition.exchangeFor(me),
    );
    expect(
      buildCabrilloExport(
        spec: spec,
        qsos: const [],
        claimedScore: 0,
        callsign: 'DO1HOZ',
      ),
      isNull,
    );
  });
}
