// The tests poke into decoded JSON on purpose.
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:math';

import 'package:test/test.dart';
import 'package:tideline_domain/src/contest/contest_definition.dart';
import 'package:tideline_domain/src/contest/contest_predicate.dart';
import 'package:tideline_domain/src/contest/contest_station.dart';
import 'package:tideline_domain/src/contest/exchange.dart';
import 'package:tideline_domain/src/contest/mode_category.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/mode.dart';

import 'cq_ww_ssb.dart';

Map<String, Object?> base() => jsonDecode(cqWwSsbJson) as Map<String, Object?>;

void expectReject(
  void Function(Map<String, Object?> json) mutate,
  ContestDefinitionError reason, {
  String? path,
}) {
  final json = base();
  mutate(json);
  try {
    ContestDefinition.parse(jsonEncode(json));
    fail('expected $reason');
  } on ContestDefinitionException catch (e) {
    expect(e.reason, reason, reason: e.toString());
    if (path != null) expect(e.path, path);
  }
}

dynamic at(Map<String, Object?> json, String key) => json[key];

void main() {
  group('ContestDefinition.parse', () {
    test('parses the CQ WW SSB example', () {
      final d = ContestDefinition.parse(cqWwSsbJson);
      expect(d.id, 'cq-ww-ssb');
      expect(d.version, 1);
      expect(d.cabrillo, 'CQ-WW-SSB');
      expect(d.modes, [ModeCategory.phone]);
      expect(d.bands.map((b) => b.name), [
        '160m',
        '80m',
        '40m',
        '20m',
        '15m',
        '10m',
      ]);
      expect(d.exchange.sent.map((e) => e.kind), [
        ExchangeKind.rst,
        ExchangeKind.cqZone,
      ]);
      expect(d.exchange.sent[1].defaultValue, '{MY_CQ_ZONE}');
      expect(d.dupe.per, [DupeKey.band, DupeKey.modeCategory]);
      expect(d.points, hasLength(4));
      expect(d.points.last.when, isNull);
      expect(d.points[1].when!.sameContinent, isFalse);
      expect(d.points[2].when!.myContinent, ['NA']);
      expect(d.multipliers.map((m) => m.source.jsonName), [
        'rcvd:cqZone',
        'dxcc',
      ]);
      expect(d.multipliers.first.per, MultiplierScope.band);
      expect(d.score, ScoreKind.pointsTimesMultipliers);
    });

    test('round trip is lossless', () {
      for (final source in [cqWwSsbJson, variantJson]) {
        final d = ContestDefinition.parse(source);
        final again = ContestDefinition.parse(jsonEncode(d.toJson()));
        expect(again, d);
        expect(again.toJson(), d.toJson());
        expect(again.hashCode, d.hashCode);
      }
    });

    test('the example needs no changes to be canonical', () {
      // The spec example already is in canonical form, apart from the
      // always-emitted `points`/`multipliers` keys it contains too.
      expect(
        ContestDefinition.parse(cqWwSsbJson).toJson(),
        jsonDecode(cqWwSsbJson),
      );
    });

    test('accepts a minimal qsos contest without points', () {
      final d = ContestDefinition.parse(
        jsonEncode({
          'schema': 1,
          'id': 'fun',
          'version': 1,
          'name': 'Fun',
          'modes': ['CW'],
          'bands': ['20M'],
          'exchange': {'sent': <Object?>[], 'rcvd': <Object?>[]},
          'dupe': {'per': <Object?>[]},
          'score': 'qsos',
        }),
      );
      expect(d.bands.single, Band.tryParse('20m'));
      expect(d.points, isEmpty);
      expect(d.dupe.slotKey(Band.tryParse('20m')!, Mode.tryParse('CW')!), '');
    });

    test('rejects what it does not understand', () {
      expectReject(
        (j) => j['extra'] = 1,
        ContestDefinitionError.unknownKey,
        path: r'$.extra',
      );
      expectReject(
        (j) => (at(j, 'exchange')['sent'] as List<Object?>)[0] = {
          'kind': 'rst',
          'foo': 1,
        },
        ContestDefinitionError.unknownKey,
        path: r'$.exchange.sent[0].foo',
      );
      expectReject(
        (j) => at(j, 'dupe')['x'] = 1,
        ContestDefinitionError.unknownKey,
      );
      expectReject(
        (j) => (at(j, 'points') as List<Object?>)[0] = {
          'when': {'sameDXCC': true},
          'points': 1,
        },
        ContestDefinitionError.unknownKey,
      );
      expectReject(
        (j) => (at(j, 'multipliers') as List<dynamic>)[0]['x'] = 1,
        ContestDefinitionError.unknownKey,
      );
      expectReject(
        (j) => at(j, 'exchange')['variants'] = [
          {
            'when': {'myDxcc': 1},
            'sent': <Object?>[],
            'z': 1,
          },
        ],
        ContestDefinitionError.unknownKey,
      );
    });

    test('rejects missing keys and wrong types', () {
      expectReject(
        (j) => j.remove('name'),
        ContestDefinitionError.missingKey,
        path: r'$.name',
      );
      expectReject((j) => j.remove('score'), ContestDefinitionError.missingKey);
      expectReject(
        (j) => j.remove('points'),
        ContestDefinitionError.missingKey,
      );
      expectReject((j) => j['version'] = '1', ContestDefinitionError.wrongType);
      expectReject((j) => j['version'] = 1.5, ContestDefinitionError.wrongType);
      expectReject((j) => j['name'] = 5, ContestDefinitionError.wrongType);
      expectReject(
        (j) => j['modes'] = 'PHONE',
        ContestDefinitionError.wrongType,
      );
      expectReject(
        (j) => j['cabrillo'] = null,
        ContestDefinitionError.wrongType,
      );
      expectReject((j) => j['exchange'] = [], ContestDefinitionError.wrongType);
      expectReject(
        (j) => at(j, 'exchange')['sent'] = 'x',
        ContestDefinitionError.wrongType,
      );
      expectReject(
        (j) =>
            (at(j, 'points') as List<dynamic>)[0]['when']['sameDxcc'] = 'yes',
        ContestDefinitionError.wrongType,
      );
      expect(
        () => ContestDefinition.parse('[]'),
        throwsA(isA<ContestDefinitionException>()),
      );
      expect(
        () => ContestDefinition.parse('{nope'),
        throwsA(
          isA<ContestDefinitionException>().having(
            (e) => e.reason,
            'reason',
            ContestDefinitionError.malformedJson,
          ),
        ),
      );
    });

    test('rejects bad schema, id, version and ranges', () {
      expectReject(
        (j) => j['schema'] = 2,
        ContestDefinitionError.unsupportedSchema,
      );
      expectReject(
        (j) => j['schema'] = 0,
        ContestDefinitionError.unsupportedSchema,
      );
      expectReject((j) => j['id'] = 'CQ_WW', ContestDefinitionError.invalidId);
      expectReject((j) => j['id'] = '', ContestDefinitionError.outOfRange);
      expectReject((j) => j['id'] = 'a' * 65, ContestDefinitionError.invalidId);
      expectReject((j) => j['id'] = '../x', ContestDefinitionError.invalidId);
      expectReject((j) => j['version'] = 0, ContestDefinitionError.outOfRange);
      expectReject(
        (j) => j['name'] = 'n' * 121,
        ContestDefinitionError.tooLong,
      );
      expectReject(
        (j) => j['name'] = 'a\u0000b',
        ContestDefinitionError.invalidCharacters,
      );
      expectReject(
        (j) => j['cabrillo'] = 'a b',
        ContestDefinitionError.invalidValue,
      );
      expectReject(
        (j) => (at(j, 'points') as List<dynamic>)[3]['points'] = 1001,
        ContestDefinitionError.outOfRange,
      );
      expectReject(
        (j) => (at(j, 'points') as List<dynamic>)[3]['points'] = -1,
        ContestDefinitionError.outOfRange,
      );
    });

    test('rejects unknown enum values and bands', () {
      expectReject(
        (j) => j['bands'] = ['11m'],
        ContestDefinitionError.unknownBand,
      );
      expectReject(
        (j) => j['modes'] = ['SSB'],
        ContestDefinitionError.unknownValue,
      );
      expectReject(
        (j) => j['score'] = 'magic',
        ContestDefinitionError.unknownValue,
      );
      expectReject(
        (j) => at(j, 'dupe')['per'] = ['call'],
        ContestDefinitionError.unknownValue,
      );
      expectReject(
        (j) => (at(j, 'exchange')['sent'] as List<dynamic>)[0]['kind'] = 'x',
        ContestDefinitionError.unknownValue,
      );
      expectReject(
        (j) => (at(j, 'points') as List<dynamic>)[1]['when'] = {
          'myContinent': 'XX',
        },
        ContestDefinitionError.unknownValue,
      );
      expectReject(
        (j) => (at(j, 'points') as List<dynamic>)[1]['when'] = {
          'band': ['20m', '99m'],
        },
        ContestDefinitionError.unknownBand,
      );
      expectReject(
        (j) => j['modes'] = [],
        ContestDefinitionError.tooFewElements,
      );
      expectReject(
        (j) => j['bands'] = ['20m', '20M'],
        ContestDefinitionError.duplicateValue,
      );
    });

    test('rejects list and size limits', () {
      expectReject(
        (j) => j['bands'] = List.filled(65, '20m'),
        ContestDefinitionError.tooManyElements,
      );
      expectReject(
        (j) => j['points'] = List.generate(65, (_) => {'points': 1}),
        ContestDefinitionError.tooManyElements,
      );
      expect(
        () => ContestDefinition.parse(
          '${' ' * ContestDefinition.maxInputBytes}$cqWwSsbJson',
        ),
        throwsA(
          isA<ContestDefinitionException>().having(
            (e) => e.reason,
            'reason',
            ContestDefinitionError.tooLarge,
          ),
        ),
      );
      // Within the character limit but over the byte limit.
      expect(
        () => ContestDefinition.parse(
          '${' ' * 100}${'ä' * (ContestDefinition.maxInputBytes ~/ 2)}',
        ),
        throwsA(
          isA<ContestDefinitionException>().having(
            (e) => e.reason,
            'reason',
            ContestDefinitionError.tooLarge,
          ),
        ),
      );
    });

    test('rejects point rule problems', () {
      expectReject(
        (j) =>
            (at(j, 'points') as List<dynamic>)[3]['when'] = {'sameDxcc': true},
        ContestDefinitionError.lastRuleHasWhen,
        path: r'$.points[3].when',
      );
      expectReject(
        (j) => j['points'] = [],
        ContestDefinitionError.tooFewElements,
      );
      expectReject(
        (j) =>
            (at(j, 'points') as List<dynamic>)[1]['when'] = <String, Object?>{},
        ContestDefinitionError.emptyPredicate,
      );
    });

    test('rejects exchange problems', () {
      expectReject(
        (j) => at(j, 'exchange')['sent'] = [
          {'kind': 'serial'},
          {'kind': 'serial'},
        ],
        ContestDefinitionError.multipleSerials,
        path: r'$.exchange.sent[1]',
      );
      expectReject(
        (j) => at(j, 'exchange')['rcvd'] = [
          {'kind': 'serial'},
          {'kind': 'serial'},
        ],
        ContestDefinitionError.multipleSerials,
      );
      expectReject(
        (j) => at(j, 'exchange')['rcvd'] = [
          {'kind': 'cqZone'},
          {'kind': 'cqZone'},
        ],
        ContestDefinitionError.duplicateField,
      );
      expectReject(
        (j) => at(j, 'exchange')['variants'] = [
          {
            'when': {'sameDxcc': true},
            'sent': <Object?>[],
          },
        ],
        ContestDefinitionError.variantPredicateNotMine,
      );
      expectReject(
        (j) => at(j, 'exchange')['variants'] = [
          {
            'when': {'myDxcc': 230, 'modeCategory': 'CW'},
            'sent': <Object?>[],
          },
        ],
        ContestDefinitionError.variantPredicateNotMine,
      );
      expectReject(
        (j) => at(j, 'exchange')['variants'] = [
          {
            'when': {'myDxcc': 230},
          },
        ],
        ContestDefinitionError.missingKey,
      );
      expectReject(
        (j) => at(j, 'exchange')['variants'] = [
          {
            'when': {'myDxcc': 230},
            'sent': [
              {'kind': 'serial'},
              {'kind': 'serial'},
            ],
          },
        ],
        ContestDefinitionError.multipleSerials,
      );
    });

    test('rejects element defaults that are not allowed', () {
      expectReject(
        (j) => (at(j, 'exchange')['rcvd'] as List<dynamic>)[1]['default'] = '5',
        ContestDefinitionError.defaultNotAllowed,
      );
      expectReject(
        (j) => at(j, 'exchange')['sent'] = [
          {'kind': 'serial', 'default': '1'},
        ],
        ContestDefinitionError.defaultNotAllowed,
      );
      expectReject(
        (j) => (at(j, 'exchange')['sent'] as List<dynamic>)[1]['default'] =
            '{MY_NOPE}',
        ContestDefinitionError.invalidPlaceholder,
      );
      expectReject(
        (j) => (at(j, 'exchange')['sent'] as List<dynamic>)[1]['default'] =
            '{MY_CQ_ZONE',
        ContestDefinitionError.invalidPlaceholder,
      );
      expectReject(
        (j) =>
            (at(j, 'exchange')['sent'] as List<dynamic>)[1]['default'] = '99',
        ContestDefinitionError.invalidValue,
      );
      expectReject(
        (j) => (at(j, 'exchange')['sent'] as List<dynamic>)[1]['label'] = 'A B',
        ContestDefinitionError.invalidValue,
      );
    });

    test('rejects multiplier problems', () {
      expectReject(
        (j) => (at(j, 'multipliers') as List<dynamic>)[0]['source'] =
            'rcvd:ituZone',
        ContestDefinitionError.invalidMultiplierSource,
      );
      expectReject(
        (j) => (at(j, 'multipliers') as List<dynamic>)[0]['source'] = 'grid4',
        ContestDefinitionError.invalidMultiplierSource,
      );
      expectReject(
        (j) =>
            (at(j, 'multipliers') as List<dynamic>)[0]['source'] = 'rcvd:rst',
        ContestDefinitionError.invalidMultiplierSource,
      );
      expectReject(
        (j) => (at(j, 'multipliers') as List<dynamic>)[0]['source'] = 'magic',
        ContestDefinitionError.invalidMultiplierSource,
      );
      expectReject(
        (j) => (at(j, 'multipliers') as List<dynamic>)[1]['id'] = 'zone',
        ContestDefinitionError.duplicateId,
      );
      expectReject(
        (j) => (at(j, 'multipliers') as List<dynamic>)[1]['id'] = 'Bad Id',
        ContestDefinitionError.invalidId,
      );
      expectReject(
        (j) => (at(j, 'multipliers') as List<dynamic>)[1]['per'] = 'always',
        ContestDefinitionError.unknownValue,
      );
      expectReject(
        (j) => j['multipliers'] = [],
        ContestDefinitionError.invalidCombination,
      );
      expectReject(
        (j) => j['score'] = 'points',
        ContestDefinitionError.invalidCombination,
      );
    });
  });

  group('exchangeFor', () {
    final wag = ContestDefinition.parse(variantJson);
    test('uses the base exchange when no variant matches', () {
      final ex = wag.exchangeFor(
        const ContestStation(call: 'K1ABC', dxcc: 291),
      );
      expect(ex.sent.map((e) => e.kind), [
        ExchangeKind.rst,
        ExchangeKind.serial,
      ]);
      expect(ex.rcvd, hasLength(3));
    });

    test('uses the first matching variant, keeping the other side', () {
      final ex = wag.exchangeFor(const ContestStation(call: 'DL1A', dxcc: 230));
      expect(ex.sent.map((e) => e.kind), [
        ExchangeKind.rst,
        ExchangeKind.serial,
        ExchangeKind.dok,
      ]);
      expect(ex.rcvd, same(wag.exchange.rcvd));
    });

    test('unknown station data does not match a variant', () {
      final ex = wag.exchangeFor(const ContestStation(call: 'DL1A'));
      expect(ex.sent, hasLength(2));
    });
  });

  group('ContestPredicate', () {
    const de = ContestStation(call: 'DL1A', dxcc: 230, continent: 'EU');
    const us = ContestStation(call: 'K1A', dxcc: 291, continent: 'NA');
    const unknown = ContestStation(call: 'XX1A');
    ContestPredicate p(Map<String, Object?> json) =>
        ContestPredicate.fromJson(json, r'$');

    test('same / different entity and continent', () {
      expect(p({'sameDxcc': true}).matches(me: de, them: de), isTrue);
      expect(p({'sameDxcc': true}).matches(me: de, them: us), isFalse);
      expect(p({'sameDxcc': false}).matches(me: de, them: us), isTrue);
      expect(p({'sameContinent': false}).matches(me: de, them: us), isTrue);
      expect(p({'sameContinent': true}).matches(me: de, them: us), isFalse);
    });

    test('lists and scalars', () {
      expect(p({'theirContinent': 'NA'}).matches(them: us), isTrue);
      expect(
        p({
          'theirContinent': ['EU', 'NA'],
        }).matches(them: us),
        isTrue,
      );
      expect(p({'myDxcc': 230}).matches(me: de), isTrue);
      expect(
        p({
          'theirDxcc': [1, 230],
        }).matches(them: us),
        isFalse,
      );
      final band = Band.tryParse('20m');
      expect(p({'band': '20m'}).matches(qsoBand: band), isTrue);
      expect(
        p({
          'band': ['40m', '80m'],
        }).matches(qsoBand: band),
        isFalse,
      );
      expect(
        p({'modeCategory': 'CW'}).matches(category: ModeCategory.cw),
        isTrue,
      );
    });

    test('all keys must hold; unknown data is false', () {
      final both = p({'myContinent': 'EU', 'theirContinent': 'NA'});
      expect(both.matches(me: de, them: us), isTrue);
      expect(both.matches(me: us, them: us), isFalse);
      for (final json in [
        {'sameDxcc': false},
        {'sameDxcc': true},
        {'sameContinent': false},
        {'myContinent': 'EU'},
        {'theirDxcc': 291},
        {'band': '20m'},
        {'modeCategory': 'CW'},
      ]) {
        expect(
          p(json).matches(me: unknown, them: unknown),
          isFalse,
          reason: '$json',
        );
      }
      expect(p({'sameDxcc': false}).matches(), isFalse);
    });

    test('onlyMine', () {
      expect(p({'myDxcc': 1, 'myContinent': 'EU'}).onlyMine, isTrue);
      expect(p({'myDxcc': 1, 'band': '20m'}).onlyMine, isFalse);
    });

    test('toJson writes single values bare', () {
      expect(
        p({
          'myContinent': ['NA'],
        }).toJson(),
        {'myContinent': 'NA'},
      );
      expect(
        p({
          'band': ['20m', '40m'],
        }).toJson(),
        {
          'band': ['20m', '40m'],
        },
      );
    });
  });

  group('ModeCategory', () {
    test('maps ADIF modes', () {
      ModeCategory cat(String m) => ModeCategory.of(Mode.tryParse(m)!);
      expect(cat('CW'), ModeCategory.cw);
      expect(cat('PCW'), ModeCategory.cw);
      for (final m in [
        'SSB',
        'USB',
        'LSB',
        'AM',
        'FM',
        'DIGITALVOICE',
        'C4FM',
      ]) {
        expect(cat(m), ModeCategory.phone, reason: m);
      }
      for (final m in ['RTTY', 'FT8', 'FT4', 'PSK31', 'MFSK', 'JT65']) {
        expect(cat(m), ModeCategory.digi, reason: m);
      }
      expect(ModeCategory.tryParse('PHONE'), ModeCategory.phone);
      expect(ModeCategory.tryParse('phone'), isNull);
    });
  });

  group('fuzz', () {
    test('mutated definitions parse or throw ContestDefinitionException', () {
      final random = Random(18);
      const junkCount = 16;
      Object? junkAt(int i) => <Object? Function()>[
        () => null,
        () => true,
        () => 0,
        () => -1,
        () => 1.5,
        () => 1 << 40,
        () => '',
        () => 'x' * 300,
        () => 'rcvd:cqZone',
        () => '20m',
        () => <Object?>[],
        () => <String, Object?>{},
        () => <Object?>[<Object?>[]],
        () => <String, Object?>{'a': 1},
        () => '\u0000',
        () => '{MY_CQ_ZONE}',
      ][i]();
      Object? mutate(Object? node) {
        if (node is Map<String, Object?>) {
          if (node.isEmpty || random.nextInt(6) == 0) {
            node[random.nextBool() ? 'zzz' : 'when'] = junkAt(
              random.nextInt(junkCount),
            );
          } else {
            final key = node.keys.elementAt(random.nextInt(node.length));
            final r = random.nextInt(4);
            if (r == 0) {
              node.remove(key);
            } else if (r == 1) {
              node[key] = junkAt(random.nextInt(junkCount));
            } else {
              node[key] = mutate(node[key]);
            }
          }
        } else if (node is List<Object?>) {
          if (node.isEmpty || random.nextInt(5) == 0) {
            node.add(junkAt(random.nextInt(junkCount)));
          } else {
            final i = random.nextInt(node.length);
            if (random.nextInt(4) == 0) {
              node.removeAt(i);
            } else {
              node[i] = mutate(node[i]);
            }
          }
        } else {
          return junkAt(random.nextInt(junkCount));
        }
        return node;
      }

      var parsed = 0;
      var rejected = 0;
      for (var i = 0; i < 3000; i++) {
        final source = i.isEven ? cqWwSsbJson : variantJson;
        var root = jsonDecode(source);
        for (var k = 0; k <= random.nextInt(3); k++) {
          root = mutate(root);
        }
        try {
          ContestDefinition.fromJson(root);
          parsed++;
        } on ContestDefinitionException {
          rejected++;
        }
      }
      expect(rejected, greaterThan(1000));
      expect(parsed, greaterThan(0));
    });

    test('character-level mutations never throw anything else', () {
      final random = Random(7);
      const chars = ['{', '}', '[', ']', '"', ',', ':', '0', 'a', ' ', r'\'];
      for (var i = 0; i < 2000; i++) {
        final codes = (i.isEven ? cqWwSsbJson : variantJson).codeUnits.toList();
        for (var k = 0; k <= random.nextInt(4); k++) {
          final pos = random.nextInt(codes.length);
          switch (random.nextInt(3)) {
            case 0:
              codes[pos] = chars[random.nextInt(chars.length)].codeUnitAt(0);
            case 1:
              codes.removeAt(pos);
            default:
              codes.insert(
                pos,
                chars[random.nextInt(chars.length)].codeUnitAt(0),
              );
          }
        }
        try {
          ContestDefinition.parse(String.fromCharCodes(codes));
        } on ContestDefinitionException {
          // expected
        }
      }
    });

    test('deeply nested input is rejected, not a crash', () {
      final deep = '${'[' * 5000}${']' * 5000}';
      expect(
        () => ContestDefinition.parse(deep),
        throwsA(isA<ContestDefinitionException>()),
      );
      final deepObject = '{"schema":1,"id":"x",${'"a":{' * 3000}${'}' * 3000}}';
      expect(
        () => ContestDefinition.parse(deepObject),
        throwsA(isA<ContestDefinitionException>()),
      );
    });
  });
}
