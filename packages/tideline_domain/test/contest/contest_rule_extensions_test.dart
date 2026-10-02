import 'dart:convert';

import 'package:test/test.dart';
import 'package:tideline_domain/src/contest/contest_definition.dart';
import 'package:tideline_domain/src/contest/contest_predicate.dart';
import 'package:tideline_domain/src/contest/contest_scorer.dart';
import 'package:tideline_domain/src/contest/contest_station.dart';
import 'package:tideline_domain/src/contest/exchange.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/mode.dart';
import 'package:tideline_domain/src/values/utc_date_time.dart';

import 'cq_ww_ssb.dart';

const de = ContestStation(
  call: 'DO1HOZ',
  dxcc: 230,
  continent: 'EU',
  cqz: 14,
  ituz: 28,
);
const us = ContestStation(
  call: 'K1ABC',
  dxcc: 291,
  continent: 'NA',
  cqz: 5,
  ituz: 8,
);
const unknown = ContestStation(call: 'XX1A');

ContestPredicate p(Map<String, Object?> json) =>
    ContestPredicate.fromJson(json, r'$');

void expectReject(
  Map<String, Object?> Function(Map<String, Object?> json) mutate,
  ContestDefinitionError reason,
) {
  final json = mutate(jsonDecode(elementWhenJson) as Map<String, Object?>);
  try {
    ContestDefinition.parse(jsonEncode(json));
    fail('expected $reason');
  } on ContestDefinitionException catch (e) {
    expect(e.reason, reason, reason: e.toString());
  }
}

Map<String, Object?> rcvdVariant(Map<String, Object?> json) =>
    ((json['exchange']! as Map)['variants'] as List).single
        as Map<String, Object?>;

void main() {
  group('zone predicates', () {
    test('sameCqZone and sameItuZone compare my and their zone', () {
      const sameCq = ContestStation(call: 'DL1A', cqz: 14, ituz: 28);
      const otherCq = ContestStation(call: 'OH2A', cqz: 15, ituz: 18);
      expect(p({'sameCqZone': true}).matches(me: de, them: sameCq), isTrue);
      expect(p({'sameCqZone': true}).matches(me: de, them: otherCq), isFalse);
      expect(p({'sameCqZone': false}).matches(me: de, them: otherCq), isTrue);
      expect(p({'sameItuZone': true}).matches(me: de, them: sameCq), isTrue);
      expect(p({'sameItuZone': false}).matches(me: de, them: sameCq), isFalse);
      expect(p({'sameItuZone': false}).matches(me: de, them: us), isTrue);
    });

    test('an unknown zone on either side is false, for true and false', () {
      for (final key in ['sameCqZone', 'sameItuZone']) {
        for (final value in [true, false]) {
          final pred = p({key: value});
          expect(pred.matches(me: de, them: unknown), isFalse);
          expect(pred.matches(me: unknown, them: us), isFalse);
          expect(pred.matches(), isFalse);
        }
      }
    });

    test('the received exchange zone takes precedence over the resolver', () {
      const resolver = ContestStation(
        call: 'DL1A',
        dxcc: 230,
        continent: 'EU',
        cqz: 14,
        ituz: 28,
      );
      ContestQso qso(Map<ExchangeKind, String> rcvd) => ContestQso(
        id: '1',
        call: 'DL1A',
        time: UtcDateTime(DateTime.utc(2026, 10, 24, 10)),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('USB')!,
        me: de,
        them: resolver,
        rcvd: rcvd,
      );
      expect(qso({}).themForRules.cqz, 14);
      final over = qso({ExchangeKind.cqZone: '15', ExchangeKind.ituZone: '27'});
      expect(over.themForRules.cqz, 15);
      expect(over.themForRules.ituz, 27);
      // An invalid received value does not erase the resolver's zone.
      expect(qso({ExchangeKind.cqZone: '99'}).themForRules.cqz, 14);

      final d = ContestDefinition.parse(
        jsonEncode({
          ...jsonDecode(cqWwSsbJson) as Map<String, Object?>,
          'points': [
            {
              'when': {'sameCqZone': true},
              'points': 1,
            },
            {'points': 3},
          ],
        }),
      );
      int points(ContestQso q) => ContestScorer.scoreAll(d, [q]).score.points;
      expect(points(qso({})), 1);
      expect(points(qso({ExchangeKind.cqZone: '15'})), 3);
    });

    test('they are not allowed in exchange variants', () {
      expect(p({'sameCqZone': true}).onlyMine, isFalse);
      expect(p({'sameItuZone': false}).onlyMine, isFalse);
      expect(p({'sameItuZone': false}).onlyTheirs, isFalse);
    });
  });

  group('negated lists', () {
    test('hold when the value is known and not listed', () {
      expect(p({'theirDxccNot': 230}).matches(them: us), isTrue);
      expect(p({'theirDxccNot': 291}).matches(them: us), isFalse);
      expect(
        p({
          'theirDxccNot': [1, 291],
        }).matches(them: us),
        isFalse,
      );
      expect(
        p({
          'myDxccNot': [1, 291],
        }).matches(me: de),
        isTrue,
      );
      expect(p({'myContinentNot': 'NA'}).matches(me: de), isTrue);
      expect(p({'myContinentNot': 'EU'}).matches(me: de), isFalse);
      expect(
        p({
          'theirContinentNot': ['EU', 'AF'],
        }).matches(them: us),
        isTrue,
      );
    });

    test('unknown values never hold', () {
      for (final json in [
        {'myDxccNot': 1},
        {'theirDxccNot': 1},
        {'myContinentNot': 'EU'},
        {'theirContinentNot': 'EU'},
      ]) {
        expect(
          p(json).matches(me: unknown, them: unknown),
          isFalse,
          reason: '$json',
        );
        expect(p(json).matches(), isFalse, reason: '$json');
      }
    });

    test('onlyMine and onlyTheirs', () {
      expect(p({'myDxccNot': 1, 'myContinentNot': 'EU'}).onlyMine, isTrue);
      expect(p({'theirDxccNot': 1}).onlyMine, isFalse);
      expect(p({'theirContinentNot': 'EU'}).onlyMine, isFalse);
      expect(p({'theirDxccNot': 1, 'theirContinent': 'EU'}).onlyTheirs, isTrue);
      expect(p({'myDxccNot': 1}).onlyTheirs, isFalse);
      expect(p({'theirDxcc': 1, 'band': '20m'}).onlyTheirs, isFalse);
    });

    test('are validated like their positive forms', () {
      for (final json in [
        {'theirDxccNot': 0},
        {'theirDxccNot': 'x'},
        {'myContinentNot': 'XX'},
        {'theirContinentNot': <Object?>[]},
        {'sameCqZone': 1},
        {'sameItuZone': 'yes'},
      ]) {
        expect(
          () => p(json),
          throwsA(isA<ContestDefinitionException>()),
          reason: '$json',
        );
      }
    });

    test('round trip with single values written bare', () {
      final json = {
        'myDxccNot': 230,
        'theirDxccNot': [1, 291],
        'myContinentNot': 'AF',
        'theirContinentNot': ['AF', 'AN'],
        'sameCqZone': false,
        'sameItuZone': true,
      };
      expect(p(json).toJson(), json);
    });

    test('variants may use myDxccNot, not theirDxccNot', () {
      final ok = jsonDecode(elementWhenJson) as Map<String, Object?>;
      expect(() => ContestDefinition.fromJson(ok), returnsNormally);
      expectReject(
        (j) => j..['exchange'] = _withVariantWhen(j, {'theirDxccNot': 230}),
        ContestDefinitionError.variantPredicateNotMine,
      );
    });
  });

  group('received elements keyed on the other station', () {
    final d = ContestDefinition.parse(elementWhenJson);
    final rcvd = d.exchangeFor(de).rcvd;
    const dl = ContestStation(call: 'DL1A', dxcc: 230, continent: 'EU');

    test('parse and round trip', () {
      expect(rcvd[1].when, isNotNull);
      expect(ContestDefinition.fromJson(d.toJson()), d);
      expect(
        (d.toJson()['exchange']! as Map)['variants'],
        contains(
          containsPair('rcvd', contains(containsPair('when', anything))),
        ),
      );
    });

    test('presence follows the other station', () {
      ExchangePresence pres(int i, ContestStation? them) =>
          rcvd[i].presenceFor(them);
      expect(pres(0, null), ExchangePresence.required);
      expect(pres(1, us), ExchangePresence.required);
      expect(pres(2, us), ExchangePresence.absent);
      expect(pres(1, dl), ExchangePresence.absent);
      expect(pres(2, dl), ExchangePresence.required);
      // Unknown DXCC: both are optional.
      expect(pres(1, unknown), ExchangePresence.optional);
      expect(pres(2, unknown), ExchangePresence.optional);
      expect(pres(2, null), ExchangePresence.optional);
    });

    test('an element that matches keeps its own optional flag', () {
      const e = ExchangeElement(
        kind: ExchangeKind.dok,
        optional: true,
        when: ContestPredicate(theirDxcc: [230]),
      );
      expect(e.presenceFor(dl), ExchangePresence.optional);
      expect(e.presenceFor(us), ExchangePresence.absent);
    });

    test('checkRcvd validates only the elements that apply', () {
      final ex = d.exchangeFor(de);
      var r = ex.checkRcvd(['59', '12', ''], them: us);
      expect(r.map((c) => c.presence), [
        ExchangePresence.required,
        ExchangePresence.required,
        ExchangePresence.absent,
      ]);
      expect(r.every((c) => c.isValid), isTrue);
      expect(r[1].value, '12');

      r = ex.checkRcvd(['59', '', ''], them: us);
      expect(r[1].error, ExchangeError.missing);

      // A stale value in an absent field is dropped without an error.
      r = ex.checkRcvd(['59', 'garbage', 'A01'], them: us);
      expect(r[2].value, isNull);
      expect(r[2].isValid, isTrue);

      r = ex.checkRcvd(['59', '', 'a01'], them: dl);
      expect(r[1].isValid, isTrue);
      expect(r[2].value, 'A01');
      r = ex.checkRcvd(['59', '', ''], them: dl);
      expect(r[2].error, ExchangeError.missing);
      r = ex.checkRcvd(['59', '', 'A-1'], them: dl);
      expect(r[2].error, ExchangeError.invalidFormat);

      // Unknown station: both optional, so empty is fine, a bad value not.
      r = ex.checkRcvd(['59', '', ''], them: unknown);
      expect(r.every((c) => c.isValid), isTrue);
      r = ex.checkRcvd(['59', '0', ''], them: unknown);
      expect(r[1].error, ExchangeError.outOfRange);

      expect(() => ex.checkRcvd(['59'], them: us), throwsArgumentError);
      expect(ex.checkSent(['59', 'A01']).every((c) => c.isValid), isTrue);
    });

    test('ADIF mapping skips absent elements and round-trips', () {
      final adif = ExchangeMapping.toAdif(ExchangeSide.rcvd, rcvd, [
        '59',
        '12',
        'A01',
      ], them: us);
      // The DOK is absent for a US station: not stored.
      expect(adif.fields, {'SRX': '12', 'SRX_STRING': '59 12'});
      expect(
        ExchangeMapping.fromAdif(
          ExchangeSide.rcvd,
          rcvd,
          rst: adif.rst,
          fields: adif.fields,
          them: us,
        ),
        ['59', '12', ''],
      );
      final fromDl = ExchangeMapping.toAdif(ExchangeSide.rcvd, rcvd, [
        '59',
        '',
        'A01',
      ], them: dl);
      expect(fromDl.fields, {'DARC_DOK': 'A01', 'SRX_STRING': '59 A01'});
      expect(
        ExchangeMapping.fromAdif(
          ExchangeSide.rcvd,
          rcvd,
          rst: fromDl.rst,
          fields: fromDl.fields,
          them: dl,
        ),
        ['59', '', 'A01'],
      );
    });

    test('absent elements take no token from a shared string field', () {
      const elements = [
        ExchangeElement(kind: ExchangeKind.name),
        ExchangeElement(
          kind: ExchangeKind.text,
          when: ContestPredicate(theirDxcc: [230]),
        ),
        ExchangeElement(kind: ExchangeKind.cqZone),
      ];
      // Sent-side names share STX_STRING; use the received side where the
      // text kind owns SRX_STRING and name/cqZone have their own fields.
      final back = ExchangeMapping.fromAdif(
        ExchangeSide.rcvd,
        elements,
        fields: {'NAME': 'JOERG', 'CQZ': '14', 'SRX_STRING': 'XYZ'},
        them: us,
      );
      expect(back, ['JOERG', '', '14']);
    });

    test('Cabrillo tokens: absent elements produce no token', () {
      expect(ExchangeMapping.cabrilloTokens(rcvd, ['59', '12', ''], them: us), [
        '59',
        '12',
      ]);
      expect(
        ExchangeMapping.cabrilloTokens(rcvd, ['59', '', 'a01'], them: dl),
        ['59', 'A01'],
      );
      expect(
        ExchangeMapping.cabrilloTokens(rcvd, ['59', '12', ''], them: unknown),
        ['59', '12', ''],
      );
    });

    test('the parser stays strict', () {
      // `when` on a sent element.
      expectReject((j) {
        final sent = (j['exchange']! as Map)['sent'] as List;
        (sent[1] as Map)['when'] = {'theirDxcc': 230};
        return j;
      }, ContestDefinitionError.elementWhenNotAllowed);
      // Not a their* predicate.
      for (final when in [
        {'myDxcc': 230},
        {'sameDxcc': false},
        {'band': '20m'},
        {'theirDxcc': 230, 'modeCategory': 'CW'},
        {'sameCqZone': true},
      ]) {
        expectReject((j) {
          final list = rcvdVariant(j)['rcvd']! as List;
          (list[1] as Map)['when'] = when;
          return j;
        }, ContestDefinitionError.elementPredicateNotTheirs);
      }
      expectReject((j) {
        final list = rcvdVariant(j)['rcvd']! as List;
        (list[1] as Map)['when'] = <String, Object?>{};
        return j;
      }, ContestDefinitionError.emptyPredicate);
      expectReject((j) {
        final list = rcvdVariant(j)['rcvd']! as List;
        (list[1] as Map)['when'] = {'theirDxcc': 230, 'bogus': true};
        return j;
      }, ContestDefinitionError.unknownKey);
      // Two alternatives of one kind store into the same ADIF field.
      expectReject((j) {
        (rcvdVariant(j)['rcvd']! as List).add({
          'kind': 'serial',
          'when': {'theirDxcc': 1},
        });
        return j;
      }, ContestDefinitionError.multipleSerials);
    });
  });

  group('DOK district multiplier', () {
    final d = ContestDefinition.parse(elementWhenJson);
    const fi = ContestStation(call: 'OH2AA', dxcc: 224, continent: 'EU');

    test('counts the first letter, not NM, once per band and mode', () {
      ContestQso q(int m, String call, String? dok, {String mode = 'CW'}) =>
          ContestQso(
            id: '$m',
            call: call,
            time: UtcDateTime(DateTime.utc(2026, 10, 24, 10, m)),
            band: Band.tryParse('20m')!,
            mode: Mode.tryParse(mode)!,
            me: fi,
            them: const ContestStation(call: 'DL', dxcc: 230, continent: 'EU'),
            rcvd: {ExchangeKind.dok: ?dok},
          );
      final report = ContestScorer.scoreAll(d, [
        q(0, 'DL1A', 'A01'),
        q(1, 'DL2B', 'a15'),
        q(2, 'DL3C', 'B02'),
        q(3, 'DL4D', 'NM'),
        q(4, 'DL5E', '50R'),
        q(5, 'DL6F', null),
        q(6, 'DL1A', 'A01', mode: 'USB'),
      ]);
      expect(report.score.multipliers, 3);
      expect(
        [for (final s in report.perQso) s.newMultipliers.map((h) => h.value)],
        [
          ['A'],
          <String>[],
          ['B'],
          <String>[],
          <String>[],
          <String>[],
          ['A'],
        ],
      );
    });

    test('needs a received DOK element', () {
      final json = jsonDecode(elementWhenJson) as Map<String, Object?>;
      (json['exchange']! as Map<String, Object?>).remove('variants');
      try {
        ContestDefinition.fromJson(json);
        fail('expected a rejection');
      } on ContestDefinitionException catch (e) {
        expect(e.reason, ContestDefinitionError.invalidMultiplierSource);
      }
    });
  });
}

Map<String, Object?> _withVariantWhen(
  Map<String, Object?> json,
  Map<String, Object?> when,
) {
  final exchange = json['exchange']! as Map<String, Object?>;
  final variant =
      (exchange['variants']! as List).single as Map<String, Object?>;
  variant['when'] = when;
  return exchange;
}
