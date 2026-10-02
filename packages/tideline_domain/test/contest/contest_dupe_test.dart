import 'dart:convert';

import 'package:test/test.dart';
import 'package:tideline_domain/src/contest/contest_definition.dart';
import 'package:tideline_domain/src/contest/contest_dupe.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/mode.dart';

import 'cq_ww_ssb.dart';

ContestContact contact(String id, String call, String band, String mode) =>
    ContestContact(
      id: id,
      call: call,
      band: Band.tryParse(band)!,
      mode: Mode.tryParse(mode)!,
    );

ContestDefinition withPer(List<String> per) {
  final json = jsonDecode(cqWwSsbJson) as Map<String, Object?>;
  json['dupe'] = {'per': per};
  return ContestDefinition.parse(jsonEncode(json));
}

DupeResult check(
  ContestDupeChecker c,
  String call,
  String band,
  String mode, {
  String? excludeId,
}) => c.check(
  call: call,
  band: Band.tryParse(band)!,
  mode: Mode.tryParse(mode)!,
  excludeId: excludeId,
);

void main() {
  group('ContestDupeChecker (per band + modeCategory)', () {
    final checker = ContestDupeChecker(withPer(['band', 'modeCategory']), [
      contact('1', 'k1abc', '20m', 'USB'),
      contact('2', 'K1ABC', '40m', 'LSB'),
      contact('3', 'DL2XYZ', '20m', 'CW'),
    ]);

    test('same call, band and category is a dupe (USB vs LSB)', () {
      final r = check(checker, 'K1ABC', '20m', 'SSB');
      expect(r.isDupe, isTrue);
      expect(r.workedBands.map((b) => b.name), ['40m', '20m']);
      expect(r.workedModes, ['SSB']);
    });

    test('another band is not a dupe but is reported as worked', () {
      final r = check(checker, 'k1abc', '15m', 'SSB');
      expect(r.isDupe, isFalse);
      expect(r.workedBands.map((b) => b.name), ['40m', '20m']);
    });

    test('another mode category is not a dupe', () {
      final r = check(checker, 'DL2XYZ', '20m', 'SSB');
      expect(r.isDupe, isFalse);
      expect(r.workedCategories.map((c) => c.jsonName), ['CW']);
    });

    test('portable calls are different calls', () {
      expect(check(checker, 'K1ABC/P', '20m', 'SSB').isDupe, isFalse);
    });

    test('an unknown call has no history', () {
      final r = check(checker, 'W9ZZZ', '20m', 'SSB');
      expect(r.isDupe, isFalse);
      expect(r.previous, isEmpty);
      expect(r.workedBands, isEmpty);
    });

    test('the QSO being edited is excluded', () {
      expect(
        check(checker, 'K1ABC', '20m', 'SSB', excludeId: '1').isDupe,
        isFalse,
      );
      expect(
        check(checker, 'K1ABC', '20m', 'SSB', excludeId: '2').isDupe,
        isTrue,
      );
    });
  });

  group('other dupe rules', () {
    test('per mode distinguishes CW from RTTY but not USB from LSB', () {
      final c = ContestDupeChecker(withPer(['band', 'mode']), [
        contact('1', 'K1ABC', '20m', 'USB'),
      ]);
      expect(check(c, 'K1ABC', '20m', 'LSB').isDupe, isTrue);
      expect(check(c, 'K1ABC', '20m', 'FM').isDupe, isFalse);
    });

    test('per [] means once per contest', () {
      final c = ContestDupeChecker(withPer([]), [
        contact('1', 'K1ABC', '20m', 'USB'),
      ]);
      expect(check(c, 'K1ABC', '10m', 'CW').isDupe, isTrue);
      expect(check(c, 'K1ABD', '10m', 'CW').isDupe, isFalse);
    });

    test('band only', () {
      final c = ContestDupeChecker(withPer(['band']), [
        contact('1', 'K1ABC', '20m', 'USB'),
      ]);
      expect(check(c, 'K1ABC', '20m', 'CW').isDupe, isTrue);
      expect(check(c, 'K1ABC', '40m', 'USB').isDupe, isFalse);
    });
  });

  group('incremental updates', () {
    test('add, replace and remove', () {
      final c = ContestDupeChecker(withPer(['band']));
      expect(c.length, 0);
      c.add(contact('1', 'K1ABC', '20m', 'SSB'));
      expect(check(c, 'K1ABC', '20m', 'SSB').isDupe, isTrue);
      // Replacing by id moves the contact to another band.
      c.add(contact('1', 'K1ABC', '40m', 'SSB'));
      expect(c.length, 1);
      expect(check(c, 'K1ABC', '20m', 'SSB').isDupe, isFalse);
      expect(check(c, 'K1ABC', '40m', 'SSB').isDupe, isTrue);
      c
        ..remove('1')
        ..remove('missing');
      expect(c.length, 0);
      expect(check(c, 'K1ABC', '40m', 'SSB').isDupe, isFalse);
    });
  });
}
