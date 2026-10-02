import 'package:test/test.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_domain/tideline_domain.dart';

const _w = CabrilloWriter();

CabrilloHeader _header({List<String> soapbox = const [], String? name}) =>
    CabrilloHeader(
      contest: 'cq-ww-ssb',
      callsign: 'do1hoz',
      createdBy: 'Tideline 0.1.0',
      categoryOperator: 'SINGLE-OP',
      categoryBand: 'ALL',
      categoryMode: 'SSB',
      categoryPower: 'LOW',
      name: name,
      soapbox: soapbox,
    );

CabrilloQso _qso(
  int hz,
  String their,
  List<String> rcvd, {
  CabrilloMode mode = CabrilloMode.phone,
  String? band,
  int? t,
  int minute = 0,
}) => CabrilloQso(
  frequencyHz: hz,
  mode: mode,
  time: UtcDateTime(DateTime.utc(2026, 10, 25, 14, minute)),
  myCall: 'DO1HOZ',
  sentExchange: const ['59', '14'],
  theirCall: their,
  receivedExchange: rcvd,
  band: band,
  transmitterId: t,
);

void main() {
  test('golden CQ WW SSB', () {
    final text = _w.write(_header(), [
      _qso(14195000, 'k1abc', ['59', '5']),
      _qso(7150000, 'JA1XYZ', ['59', '25'], minute: 7),
    ]);
    expect(
      text,
      'START-OF-LOG: 3.0\r\n'
      'CREATED-BY: Tideline 0.1.0\r\n'
      'CONTEST: CQ-WW-SSB\r\n'
      'CALLSIGN: DO1HOZ\r\n'
      'CATEGORY-OPERATOR: SINGLE-OP\r\n'
      'CATEGORY-BAND: ALL\r\n'
      'CATEGORY-MODE: SSB\r\n'
      'CATEGORY-POWER: LOW\r\n'
      'QSO: 14195 PH 2026-10-25 1400 DO1HOZ 59 14 K1ABC  59 5\r\n'
      'QSO:  7150 PH 2026-10-25 1407 DO1HOZ 59 14 JA1XYZ 59 25\r\n'
      'END-OF-LOG:\r\n',
    );
  });

  test('VHF band designators and fallback', () {
    String f(int hz, {String? band}) => _w
        .write(_header(), [_qso(hz, 'X1X', [], band: band)])
        .split('\r\n')
        .firstWhere((l) => l.startsWith('QSO:'))
        .split(' ')[1];
    expect(f(50313000), '50');
    expect(f(144300000), '144');
    expect(f(432200000), '432');
    expect(f(1296100000), '1.2G');
    expect(f(10368100000), '10G');
    expect(f(0, band: '2m'), '144');
    expect(f(0, band: '23cm'), '1.2G');
    expect(f(0, band: 'light'), 'LIGHT');
  });

  test('630m and 2200m are kHz', () {
    final text = _w.write(_header(), [
      _qso(136000, 'A1A', [], mode: CabrilloMode.cw),
      _qso(475700, 'B1B', [], mode: CabrilloMode.digi),
    ]);
    expect(text, contains('QSO: 136 CW'));
    expect(text, contains('QSO: 476 DG'));
  });

  test('soapbox injection stays on one line', () {
    final text = _w.write(
      _header(
        soapbox: ['x\nQSO: 14000 CW 2026-01-01 0000 A 1 B 2'],
        name: 'a\rb',
      ),
      [_qso(14000000, 'K1ABC', [])],
    );
    final lines = text.split('\r\n');
    expect(lines.where((l) => l.startsWith('QSO:')), hasLength(1));
    expect(lines, contains('SOAPBOX: x QSO: 14000 CW 2026-01-01 0000 A 1 B 2'));
    expect(lines, contains('NAME: a b'));
    expect(text.replaceAll('\r\n', '').contains(RegExp('[\r\n]')), isFalse);
  });

  test('ASCII output and CRLF', () {
    final text = _w.write(_header(name: 'Jörg Müller ✓'), [
      _qso(14000000, 'K1ABC', []),
    ]);
    expect(text, contains('NAME: Joerg Mueller ?'));
    expect(text.runes.every((r) => r < 0x80), isTrue);
    expect(RegExp(r'(?<!\r)\n').hasMatch(text), isFalse);
    expect(text.endsWith('END-OF-LOG:\r\n'), isTrue);
  });

  test('tokens uppercase, whitespace replaced, transmitter id', () {
    final text = _w.write(_header(), [
      _qso(14000000, 'k1abc', ['a b'], t: 1),
    ]);
    expect(text, contains('K1ABC A-B 1'));
  });

  test('address limits', () {
    final h = CabrilloHeader(
      contest: 'X',
      callsign: 'A',
      createdBy: 'T',
      addressLines: [for (var i = 0; i < 7; i++) 'l$i', 'y' * 50],
    );
    final issues = _w
        .validate(h, [_qso(14000000, 'K1ABC', [])])
        .map((i) => i.kind);
    expect(issues, contains(CabrilloIssueKind.tooManyAddressLines));
    expect(issues, contains(CabrilloIssueKind.addressLineTooLong));
    final text = _w.write(h, []);
    expect('ADDRESS:'.allMatches(text), hasLength(6));
  });

  test('validation issues', () {
    final issues = _w.validate(
      const CabrilloHeader(contest: ' ', callsign: '', createdBy: 'T'),
      [],
    );
    expect(
      issues.map((i) => i.kind),
      containsAll([
        CabrilloIssueKind.missingContest,
        CabrilloIssueKind.missingCallsign,
        CabrilloIssueKind.emptyLog,
      ]),
    );
    final mism = _w.validate(_header(), [
      _qso(14000000, 'A1A', ['59', '5']),
      _qso(14000000, 'B1B', ['59']),
      _qso(0, 'C1C', ['59', '5']),
    ]);
    expect(
      mism.map((i) => (i.kind, i.qsoIndex)),
      containsAll([
        (CabrilloIssueKind.exchangeCountMismatch, 1),
        (CabrilloIssueKind.missingFrequency, 2),
      ]),
    );
    expect(
      _w.validate(_header(), [
        _qso(14000000, 'A1A', ['59', '5']),
      ]),
      isEmpty,
    );
  });
}
