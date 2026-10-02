import 'package:test/test.dart';
import 'package:tideline_domain/src/contest/contest_definition.dart';
import 'package:tideline_domain/src/contest/contest_station.dart';
import 'package:tideline_domain/src/contest/exchange.dart';
import 'package:tideline_domain/src/contest/mode_category.dart';

import 'cq_ww_ssb.dart';

void main() {
  group('ExchangeKind.parse', () {
    String? ok(ExchangeKind k, String raw) {
      final r = k.parse(raw);
      expect(r.error, isNull, reason: '$k $raw');
      return r.value;
    }

    ExchangeError? err(ExchangeKind k, String raw) {
      final r = k.parse(raw);
      expect(r.value, isNull, reason: '$k $raw');
      return r.error;
    }

    test('rst', () {
      expect(ok(ExchangeKind.rst, '59'), '59');
      expect(ok(ExchangeKind.rst, ' 599 '), '599');
      expect(ok(ExchangeKind.rst, '33'), '33');
      expect(err(ExchangeKind.rst, '60'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.rst, '50'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.rst, '5999'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.rst, '-10'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.rst, ''), ExchangeError.missing);
    });

    test('serial', () {
      expect(ok(ExchangeKind.serial, '007'), '7');
      expect(ok(ExchangeKind.serial, '99999'), '99999');
      expect(err(ExchangeKind.serial, '0'), ExchangeError.outOfRange);
      expect(err(ExchangeKind.serial, '100000'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.serial, '12a'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.serial, '-3'), ExchangeError.invalidFormat);
    });

    test('zones', () {
      expect(ok(ExchangeKind.cqZone, '05'), '5');
      expect(ok(ExchangeKind.cqZone, '40'), '40');
      expect(err(ExchangeKind.cqZone, '41'), ExchangeError.outOfRange);
      expect(err(ExchangeKind.cqZone, '0'), ExchangeError.outOfRange);
      expect(ok(ExchangeKind.ituZone, '90'), '90');
      expect(err(ExchangeKind.ituZone, '91'), ExchangeError.outOfRange);
      expect(err(ExchangeKind.ituZone, 'x'), ExchangeError.invalidFormat);
    });

    test('grid', () {
      expect(ok(ExchangeKind.grid, 'jo40'), 'JO40');
      expect(ok(ExchangeKind.grid, 'jo40hd'), 'JO40hd');
      expect(err(ExchangeKind.grid, 'JO'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.grid, 'JO40hd55'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.grid, 'ZZ99'), ExchangeError.invalidFormat);
    });

    test('state, section, dok, name, text, power', () {
      expect(ok(ExchangeKind.state, 'ny'), 'NY');
      expect(err(ExchangeKind.state, 'NY1'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.state, 'NYCC'), ExchangeError.invalidFormat);
      expect(ok(ExchangeKind.section, 'ctx'), 'CTX');
      expect(err(ExchangeKind.section, 'ABCDE'), ExchangeError.invalidFormat);
      expect(ok(ExchangeKind.dok, 'a01'), 'A01');
      expect(ok(ExchangeKind.dok, 'Z99'), 'Z99');
      expect(err(ExchangeKind.dok, 'A-1'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.dok, 'ABCDEFG'), ExchangeError.invalidFormat);
      expect(ok(ExchangeKind.name, 'jörg'), 'JÖRG');
      expect(err(ExchangeKind.name, 'jo1'), ExchangeError.invalidFormat);
      expect(err(ExchangeKind.name, 'a' * 21), ExchangeError.invalidFormat);
      expect(ok(ExchangeKind.text, 'ab/12'), 'AB/12');
      expect(err(ExchangeKind.text, 'a b'), ExchangeError.invalidFormat);
      expect(
        err(ExchangeKind.text, 'ABCDEFGHIJKLM'),
        ExchangeError.invalidFormat,
      );
      expect(ok(ExchangeKind.power, 'kw'), 'KW');
      expect(ok(ExchangeKind.power, 'qrp'), 'QRP');
      expect(ok(ExchangeKind.power, '100'), '100');
      expect(err(ExchangeKind.power, '0'), ExchangeError.outOfRange);
      expect(err(ExchangeKind.power, '1.5'), ExchangeError.invalidFormat);
    });

    test('very long input is rejected', () {
      expect(
        ExchangeKind.text.parse('A' * 1000).error,
        ExchangeError.invalidFormat,
      );
    });
  });

  group('ExchangeElement', () {
    test('optional empty is fine, required empty is missing', () {
      const optional = ExchangeElement(kind: ExchangeKind.dok, optional: true);
      const required = ExchangeElement(kind: ExchangeKind.dok);
      expect(optional.check(' '), (value: null, error: null));
      expect(required.check(''), (value: null, error: ExchangeError.missing));
      expect(optional.check('x1').value, 'X1');
    });

    test('defaults resolve placeholders from my station', () {
      const me = ContestStation(
        call: 'DL1A',
        cqz: 14,
        ituz: 28,
        grid: 'jo40hd',
        state: 'ny',
        dok: 'a01',
      );
      String? def(ExchangeKind k, String d) =>
          ExchangeElement(kind: k, defaultValue: d).defaultFor(me);
      expect(def(ExchangeKind.cqZone, '{MY_CQ_ZONE}'), '14');
      expect(def(ExchangeKind.ituZone, '{MY_ITU_ZONE}'), '28');
      expect(def(ExchangeKind.grid, '{MY_GRID4}'), 'JO40');
      expect(def(ExchangeKind.state, '{MY_STATE}'), 'NY');
      expect(def(ExchangeKind.dok, '{MY_DOK}'), 'A01');
      expect(def(ExchangeKind.power, '100'), '100');
      // Unknown data gives no default.
      const nobody = ContestStation(call: 'X1A');
      expect(
        const ExchangeElement(
          kind: ExchangeKind.cqZone,
          defaultValue: '{MY_CQ_ZONE}',
        ).defaultFor(nobody),
        isNull,
      );
      // A default that is invalid after substitution is dropped.
      expect(
        const ExchangeElement(
          kind: ExchangeKind.cqZone,
          defaultValue: '{MY_ITU_ZONE}',
        ).defaultFor(const ContestStation(call: 'X', ituz: 80)),
        isNull,
      );
    });

    test('rst defaults by mode category; serial has none', () {
      const me = ContestStation(call: 'DL1A');
      const rst = ExchangeElement(kind: ExchangeKind.rst);
      expect(rst.defaultFor(me, category: ModeCategory.phone), '59');
      expect(rst.defaultFor(me, category: ModeCategory.cw), '599');
      expect(rst.defaultFor(me, category: ModeCategory.digi), '599');
      expect(rst.defaultFor(me), '599');
      expect(
        const ExchangeElement(kind: ExchangeKind.serial).defaultFor(me),
        isNull,
      );
    });

    test('CQ WW defaults from the parsed definition', () {
      final d = ContestDefinition.parse(cqWwSsbJson);
      final sent = d.exchange.sent;
      const me = ContestStation(call: 'DL1A', cqz: 14);
      expect(
        [for (final e in sent) e.defaultFor(me, category: ModeCategory.phone)],
        ['59', '14'],
      );
    });
  });

  group('ExchangeMapping', () {
    const rst = ExchangeElement(kind: ExchangeKind.rst);
    const serial = ExchangeElement(kind: ExchangeKind.serial);
    const cq = ExchangeElement(kind: ExchangeKind.cqZone);
    const dok = ExchangeElement(kind: ExchangeKind.dok, optional: true);
    const name = ExchangeElement(kind: ExchangeKind.name);
    const grid = ExchangeElement(kind: ExchangeKind.grid);

    test('CQ WW: report and zone; zone holds the string field', () {
      final sent = ExchangeMapping.toAdif(
        ExchangeSide.sent,
        [rst, cq],
        ['59', '14'],
      );
      expect(sent.rst, '59');
      expect(sent.fields, {'STX_STRING': '14'});
      final rcvd = ExchangeMapping.toAdif(
        ExchangeSide.rcvd,
        [rst, cq],
        ['57', '5'],
      );
      expect(rcvd.rst, '57');
      // CQZ holds the element; SRX_STRING gets the full exchange copy.
      expect(rcvd.fields, {'CQZ': '5', 'SRX_STRING': '57 5'});
    });

    test(
      'serial and DOK: serial in SRX, DOK in DARC_DOK, copy in SRX_STRING',
      () {
        final rcvd = ExchangeMapping.toAdif(
          ExchangeSide.rcvd,
          [rst, serial, dok],
          ['59', '12', 'A01'],
        );
        expect(rcvd.rst, '59');
        expect(rcvd.fields, {
          'SRX': '12',
          'DARC_DOK': 'A01',
          'SRX_STRING': '59 12 A01',
        });
        final sent = ExchangeMapping.toAdif(
          ExchangeSide.sent,
          [rst, serial, dok],
          ['59', '3', 'Z99'],
        );
        // The DOK is stored in STX_STRING, so no further copy is made.
        expect(sent.fields, {'STX': '3', 'STX_STRING': 'Z99'});
      },
    );

    test('two elements sharing STX_STRING are joined with one space', () {
      final sent = ExchangeMapping.toAdif(
        ExchangeSide.sent,
        [rst, name, cq],
        ['599', 'JOERG', '14'],
      );
      expect(sent.fields, {'STX_STRING': 'JOERG 14'});
      final back = ExchangeMapping.fromAdif(
        ExchangeSide.sent,
        [rst, name, cq],
        rst: sent.rst,
        fields: sent.fields,
      );
      expect(back, ['599', 'JOERG', '14']);
    });

    test('empty optional values are left out', () {
      final rcvd = ExchangeMapping.toAdif(
        ExchangeSide.rcvd,
        [rst, serial, dok],
        ['59', '12', ''],
      );
      expect(rcvd.fields, {'SRX': '12', 'SRX_STRING': '59 12'});
      final none = ExchangeMapping.toAdif(ExchangeSide.rcvd, [dok], ['']);
      expect(none.fields, isEmpty);
      expect(none.rst, isNull);
    });

    test('grid maps to MY_GRIDSQUARE / GRIDSQUARE', () {
      expect(
        ExchangeMapping.toAdif(ExchangeSide.sent, [grid], ['JO40']).fields,
        {'MY_GRIDSQUARE': 'JO40', 'STX_STRING': 'JO40'},
      );
      expect(
        ExchangeMapping.toAdif(ExchangeSide.rcvd, [grid], ['JO40']).fields,
        {'GRIDSQUARE': 'JO40', 'SRX_STRING': 'JO40'},
      );
    });

    test('round trip through ADIF for a mixed exchange', () {
      const elements = [rst, serial, cq, dok];
      const values = ['59', '12', '14', 'A01'];
      for (final side in ExchangeSide.values) {
        final adif = ExchangeMapping.toAdif(side, elements, values);
        expect(
          ExchangeMapping.fromAdif(
            side,
            elements,
            rst: adif.rst,
            fields: adif.fields,
          ),
          values,
          reason: '$side',
        );
      }
    });

    test('fromAdif tolerates missing and surplus tokens', () {
      expect(
        ExchangeMapping.fromAdif(
          ExchangeSide.sent,
          [name, cq],
          fields: {'STX_STRING': 'JOERG'},
        ),
        ['JOERG', ''],
      );
      expect(
        ExchangeMapping.fromAdif(
          ExchangeSide.sent,
          [name, cq],
          fields: {'STX_STRING': 'A 1 extra'},
        ),
        ['A', '1'],
      );
    });

    test('mismatched lengths are a programming error', () {
      expect(
        () => ExchangeMapping.toAdif(ExchangeSide.sent, [rst], []),
        throwsArgumentError,
      );
    });
  });
}
