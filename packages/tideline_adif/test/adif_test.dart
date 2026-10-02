import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_domain/tideline_domain.dart';

Uint8List bytesOf(String s) => Uint8List.fromList(utf8.encode(s));

const _sample = '''
Generated for a test <adif_ver:5>3.1.7 <programid:7>MonoLog
<EOH>
<qso_date:8>20101022 <time_on:4>0111 <call:5>ON4UN <band:3>40M
<mode:3>PSK <submode:5>PSK63 <app_monolog_compression:3>off <eor>
<QSO_DATE:8>20261002<TIME_ON:6>140533<CALL:6>DO1HOZ<FREQ:6>14.074<MODE:3>FT8
<RST_SENT:3>-10<RST_RCVD:3>-12<GRIDSQUARE:4>JO40<EOR>
''';

void main() {
  const parser = AdiParser();

  group('AdiParser', () {
    test('parses header and records, case-independent names', () {
      final doc = parser.parse(bytesOf(_sample));
      expect(doc.headerText, 'Generated for a test');
      expect(doc.headerFields, {'ADIF_VER': '3.1.7', 'PROGRAMID': 'MonoLog'});
      expect(doc.records, hasLength(2));
      expect(doc.records.first['CALL'], 'ON4UN');
      expect(doc.records.first['APP_MONOLOG_COMPRESSION'], 'off');
      expect(doc.records[1]['FREQ'], '14.074');
      expect(doc.warnings, isEmpty);
    });

    test('handles files without a header, even after a BOM and newline', () {
      final doc = parser.parse(
        Uint8List.fromList([
          0xEF, 0xBB, 0xBF, 0x0A, //
          ...utf8.encode('<CALL:5>ON4UN<QSO_DATE:8>20101022<EOR>'),
        ]),
      );
      expect(doc.headerFields, isEmpty);
      expect(doc.records.single['CALL'], 'ON4UN');
    });

    test('treats leading text without <EOH> before <EOR> as no header', () {
      final doc = parser.parse(bytesOf('\n<CALL:5>ON4UN <EOR>'));
      expect(doc.records.single['CALL'], 'ON4UN');
    });

    test('accepts UTF-8 lengths in bytes and in characters', () {
      // "Jörg" is 4 characters but 5 bytes.
      final bytesDoc = parser.parse(bytesOf('<NAME:5>Jörg<CALL:5>ON4UN<EOR>'));
      final charsDoc = parser.parse(bytesOf('<NAME:4>Jörg<CALL:5>ON4UN<EOR>'));
      for (final doc in [bytesDoc, charsDoc]) {
        expect(doc.records.single['NAME'], 'Jörg');
        expect(doc.records.single['CALL'], 'ON4UN');
      }
    });

    test('falls back to Latin-1 for legacy files', () {
      final doc = parser.parse(
        Uint8List.fromList([
          ...ascii.encode('<NAME:4>J'),
          0xF6, // ö in Latin-1
          ...ascii.encode('rg<EOR>'),
        ]),
      );
      expect(doc.records.single['NAME'], 'Jörg');
      expect(doc.warnings.single.kind, AdifWarningKind.encodingFallback);
    });

    test('reports problems instead of throwing', () {
      final doc = parser.parse(
        bytesOf('<CALL:5>ON4UN<CALL:5>DL1AB<BAD TAG><NAME:x>a<EOR><CALL:99>X'),
      );
      expect(doc.records, hasLength(2));
      expect(doc.records.first['CALL'], 'ON4UN');
      expect(
        doc.warnings.map((w) => w.kind),
        containsAll([
          AdifWarningKind.duplicateField,
          AdifWarningKind.malformedTag,
          AdifWarningKind.truncatedField,
          AdifWarningKind.missingEndOfRecord,
        ]),
      );
    });

    test('enforces limits', () {
      expect(
        () => const AdiParser(maxFieldLength: 10).parse(bytesOf('<NAME:11>x')),
        throwsA(isA<AdifLimitException>()),
      );
      expect(
        () =>
            const AdiParser(maxRecords: 1)
                .parse(bytesOf('<CALL:1>A<EOR><CALL:1>B<EOR>')),
        throwsA(isA<AdifLimitException>()),
      );
    });

    test('fuzz: random and mutated input never crashes or hangs', () {
      final random = Random(20261002);
      final valid = bytesOf(_sample);
      for (var i = 0; i < 3000; i++) {
        final Uint8List input;
        if (i.isEven) {
          input = Uint8List.fromList(
            List.generate(random.nextInt(400), (_) => random.nextInt(256)),
          );
        } else {
          final copy = Uint8List.fromList(valid);
          for (var m = 0; m < 1 + random.nextInt(12); m++) {
            copy[random.nextInt(copy.length)] = const [
              0x3C, 0x3E, 0x3A, 0x30, 0x39, 0xC3, 0xFF, 0x00, 0x20, //
            ][random.nextInt(9)];
          }
          input = copy;
        }
        try {
          final doc = parser.parse(input);
          // Results must be internally consistent.
          for (final r in doc.records) {
            expect(r.keys.every((k) => k == k.toUpperCase()), isTrue);
          }
        } on AdifLimitException {
          // Allowed: a mutated length may exceed the limit.
        }
      }
    });
  });

  group('AdiWriter', () {
    const writer = AdiWriter(programVersion: '0.1.0');

    test('writes byte lengths and round-trips through the parser', () {
      final text = writer.document([
        {'CALL': 'DO1HOZ', 'NAME': 'Jörg', 'COMMENT': '', 'QTH': 'Köln <3>'},
      ], createdUtc: DateTime.utc(2026, 10, 2, 12));
      expect(text, contains('<NAME:5>Jörg'));
      expect(text, isNot(contains('COMMENT')));
      final doc = parser.parse(bytesOf(text));
      expect(doc.headerFields['PROGRAMID'], 'Tideline');
      expect(doc.headerFields['CREATED_TIMESTAMP'], '20261002 120000');
      expect(doc.records.single, {
        'CALL': 'DO1HOZ',
        'NAME': 'Jörg',
        'QTH': 'Köln <3>',
      });
    });

    test('rejects invalid field names', () {
      expect(() => writer.record({'BAD NAME': 'x'}), throwsArgumentError);
    });
  });

  group('AdifQsoMapping', () {
    test('imports a record, normalising mode and keeping every field', () {
      final doc = parser.parse(bytesOf(_sample));
      final result = AdifQsoMapping.fromRecord(
        doc.records.first,
        id: 'q1',
        accountId: 'a1',
      );
      final qso = (result as AdifImported).qso;
      expect(qso.call.value, 'ON4UN');
      expect(qso.band.name, '40m');
      expect(qso.mode.toString(), 'PSK/PSK63');
      expect(qso.field('APP_MONOLOG_COMPRESSION'), 'off');
      expect(qso.source, QsoSource.import);
    });

    test('derives the band from FREQ when BAND is missing', () {
      final doc = parser.parse(bytesOf(_sample));
      final qso = (AdifQsoMapping.fromRecord(
        doc.records[1],
        id: 'q',
        accountId: 'a',
      ) as AdifImported).qso;
      expect(qso.band.name, '20m');
      expect(qso.freqHz, 14074000);
      expect(qso.timeOn.value, DateTime.utc(2026, 10, 2, 14, 5, 33));
    });

    test('reports every reason for a rejection', () {
      final result = AdifQsoMapping.fromRecord(
        {'CALL': 'X', 'QSO_DATE': '20260231', 'BAND': '11m', 'MODE': 'MORSE'},
        id: 'q',
        accountId: 'a',
      );
      expect((result as AdifRejected).reasons, AdifRejection.values);
    });

    test('TIME_OFF after midnight without QSO_DATE_OFF rolls the date', () {
      final qso = (AdifQsoMapping.fromRecord(
        {
          'CALL': 'DL1ABC',
          'QSO_DATE': '20261002',
          'TIME_ON': '2355',
          'TIME_OFF': '0005',
          'BAND': '20m',
          'MODE': 'CW',
        },
        id: 'q',
        accountId: 'a',
      ) as AdifImported).qso;
      expect(qso.timeOff!.value, DateTime.utc(2026, 10, 3, 0, 5));
    });

    test('export → import is lossless', () {
      final original = (AdifQsoMapping.fromRecord(
        {
          'CALL': 'EA8/DO1HOZ/P',
          'QSO_DATE': '20261002',
          'TIME_ON': '140533',
          'FREQ': '7.0305',
          'MODE': 'CW',
          'RST_SENT': '599',
          'RST_RCVD': '579',
          'MY_SOTA_REF': 'EA8/TF-001',
          'NAME': 'Ana',
          'APP_X_Y': 'z',
        },
        id: 'q',
        accountId: 'a',
      ) as AdifImported).qso;
      final record = AdifQsoMapping.toRecord(original);
      final again = (AdifQsoMapping.fromRecord(
        record,
        id: 'q',
        accountId: 'a',
      ) as AdifImported).qso;
      expect(AdifQsoMapping.toRecord(again), record);
      expect(record['BAND'], '40m');
      expect(record['FREQ'], '7.0305');
    });
  });
}
