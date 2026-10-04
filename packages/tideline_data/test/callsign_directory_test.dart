import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';

import 'support/contest_fixtures.dart';
import 'support/test_database.dart';

String _field(MapEntry<String, String> e) =>
    '<${e.key}:${e.value.length}>${e.value}';

String _adif(List<Map<String, String>> records) => [
  '<ADIF_VER:5>3.1.4 <EOH>',
  for (final r in records) '${r.entries.map(_field).join(' ')} <EOR>',
].join('\n');

void main() {
  late ContestHarness h;
  late WorkedBeforeRepository worked;
  late CallsignDirectoryRepository dir;

  setUp(() async {
    h = await ContestHarness.create(await openTestDatabase());
    worked = WorkedBeforeRepository(h.db);
    dir = CallsignDirectoryRepository(h.db);
  });

  Future<void> addAccount(String id) => h.db
      .into(h.db.accounts)
      .insert(
        AccountsCompanion.insert(
          id: id,
          label: id,
          baseUrl: 'https://$id.example.org',
          createdAt: 0,
        ),
      );

  group('learning from the local log', () {
    test('a saved QSO teaches name, place, locator and zones', () async {
      await h.qsos.log(
        testQso(
          fields: {
            'NAME': 'Anna',
            'QTH': 'Berlin',
            'GRIDSQUARE': 'jo62',
            'COUNTRY': 'Germany',
            'DXCC': '230',
            'CQZ': '14',
            'ITUZ': '28',
          },
        ),
      );
      final info = (await dir.lookup('DL1ABC'))!;
      expect(info.name, 'Anna');
      expect(info.qth, 'Berlin');
      expect(info.gridsquare, 'JO62');
      expect(info.country, 'Germany');
      expect((info.dxcc, info.cqz, info.ituz), (230, 14, 28));
    });

    test('a QSO that says nothing about the station adds nothing', () async {
      await h.qsos.log(testQso());
      expect(await dir.lookup('DL1ABC'), isNull);
      expect(await dir.count('acc'), 0);
    });

    test('the newest QSO wins per value, older ones fill the gaps', () async {
      await h.qsos.log(
        testQso(
          timeOn: 1000,
          fields: {'NAME': 'Ann', 'QTH': 'Hamburg', 'GRIDSQUARE': 'JO53'},
        ),
      );
      await h.qsos.log(
        testQso(timeOn: 5000, fields: {'NAME': 'Anna', 'QTH': 'Berlin'}),
      );
      // Arrives later but is older: fills nothing that is newer.
      await h.qsos.log(
        testQso(timeOn: 3000, fields: {'NAME': 'Anne', 'STATE': 'BE'}),
      );
      final info = (await dir.lookup('DL1ABC'))!;
      expect(info.name, 'Anna');
      expect(info.qth, 'Berlin');
      expect(info.gridsquare, 'JO53'); // only the oldest had it
      expect(info.state, 'BE'); // only the middle one had it
      expect(info.lastTime, 5000);
    });

    test('portable and prefixed calls share their home call', () async {
      await h.qsos.log(testQso(call: 'EA8/DL1ABC/P', fields: {'NAME': 'Anna'}));
      expect((await dir.lookup('DL1ABC'))!.name, 'Anna');
      expect((await dir.lookup('dl1abc/m'))!.name, 'Anna');
      expect(await dir.count('acc'), 1);
    });

    test('hostile text is cleaned and limited', () async {
      await h.qsos.log(
        testQso(
          fields: {
            'NAME': '  Anna\u0000\r\n  Lee  ${'x' * 200}',
            'GRIDSQUARE': 'not a grid',
            'DXCC': '99999',
            'CQZ': '-3',
          },
        ),
      );
      final info = (await dir.lookup('DL1ABC'))!;
      expect(info.name, startsWith('Anna Lee '));
      expect(info.name!.length, 80);
      expect(info.name, isNot(contains('\u0000')));
      expect(info.gridsquare, isNull);
      expect((info.dxcc, info.cqz), (null, null));
    });

    test(
      'deleting a QSO keeps what was learned (like the worked index)',
      () async {
        final q = testQso(fields: {'NAME': 'Anna'});
        await h.qsos.log(q);
        await h.qsos.delete(q.id, canDeleteOnServer: false);
        expect((await dir.lookup('DL1ABC'))!.name, 'Anna');
      },
    );

    test('rebuildLocal rebuilds from the log and is repeatable', () async {
      await h.qsos.log(testQso(timeOn: 1000, fields: {'NAME': 'Ann'}));
      await h.qsos.log(
        testQso(timeOn: 2000, fields: {'NAME': 'Anna', 'QTH': 'Berlin'}),
      );
      await h.qsos.log(testQso(call: 'G4XYZ', fields: {'NAME': 'Bob'}));
      await h.db.delete(h.db.callsignDirectory).go();
      await dir.rebuildLocal('acc');
      await dir.rebuildLocal('acc');
      expect(await dir.count('acc'), 2);
      final anna = (await dir.lookup('DL1ABC'))!;
      expect((anna.name, anna.qth), ('Anna', 'Berlin'));
    });

    test('the worked-before rebuild rebuilds the directory too', () async {
      await h.qsos.log(testQso(fields: {'NAME': 'Anna'}));
      await worked.rebuildAll('acc');
      expect((await dir.lookup('DL1ABC'))!.name, 'Anna');
      await worked.clear('acc');
      expect(await dir.lookup('DL1ABC'), isNull);
    });
  });

  group('learning from the server', () {
    test('the ADIF pull teaches the directory', () async {
      final result = await worked.mergeServerAdif(
        'acc',
        _adif([
          {
            'CALL': 'W1AW',
            'BAND': '20m',
            'MODE': 'CW',
            'QSO_DATE': '20240101',
            'TIME_ON': '120000',
            'NAME': 'Hiram',
            'QTH': 'Newington',
            'STATE': 'CT',
            'COUNTRY': 'United States',
          },
          {
            'CALL': 'W1AW',
            'BAND': '40m',
            'MODE': 'CW',
            'QSO_DATE': '20250101',
            'TIME_ON': '120000',
            'NAME': 'Hiram P.',
          },
        ]),
      );
      expect(result.merged, 2);
      final info = (await dir.lookup('W1AW'))!;
      expect(info.name, 'Hiram P.'); // the newer QSO
      expect(info.qth, 'Newington'); // only the older one had it
      expect(info.state, 'CT');
    });

    test('a server QSO older than the local one does not replace it', () async {
      await h.qsos.log(
        testQso(timeOn: 1_800_000_000_000, fields: {'NAME': 'Anna'}),
      );
      await worked.mergeServerAdif(
        'acc',
        _adif([
          {
            'CALL': 'DL1ABC',
            'BAND': '20m',
            'MODE': 'CW',
            'QSO_DATE': '20200101',
            'TIME_ON': '000000',
            'NAME': 'Old Name',
            'QTH': 'Old Town',
          },
        ]),
      );
      final info = (await dir.lookup('DL1ABC'))!;
      expect(info.name, 'Anna');
      expect(info.qth, 'Old Town'); // a gap the old QSO fills
    });

    test('at the cap only known stations are updated', () async {
      // The real cap is 500,000 rows; a test directory with a cap of one
      // stands in for a full account.
      await h.qsos.log(testQso(fields: {'NAME': 'Anna'}));
      final capped = _CappedDirectory(h.db, cap: 1);
      await capped.mergeServer('acc', [
        (
          call: 'DL1ABC',
          time: 9999999999,
          name: 'Anna B.',
          qth: null,
          gridsquare: null,
          country: null,
          state: null,
          dxcc: null,
          cqz: null,
          ituz: null,
        ),
        (
          call: 'G4XYZ',
          time: 9999999999,
          name: 'Bob',
          qth: null,
          gridsquare: null,
          country: null,
          state: null,
          dxcc: null,
          cqz: null,
          ituz: null,
        ),
      ]);
      expect((await dir.lookup('DL1ABC'))!.name, 'Anna B.');
      expect(await dir.lookup('G4XYZ'), isNull);
    });
  });

  group('several accounts', () {
    test('the lookup merges accounts, the newest value wins', () async {
      await addAccount('b');
      await h.qsos.log(
        testQso(timeOn: 1000, fields: {'NAME': 'Ann', 'QTH': 'Hamburg'}),
      );
      await h.qsos.log(
        testQso(timeOn: 9000, accountId: 'b', fields: {'NAME': 'Anna'}),
      );
      final info = (await dir.lookup('DL1ABC'))!;
      expect(info.name, 'Anna');
      expect(info.qth, 'Hamburg');
      // Per account underneath.
      expect(await dir.count('acc'), 1);
      expect(await dir.count('b'), 1);
    });
  });

  group('search', () {
    setUp(() async {
      await h.qsos.log(
        testQso(timeOn: 1000, fields: {'NAME': 'Anna', 'QTH': 'Berlin'}),
      );
      await h.qsos.log(
        testQso(
          call: 'DL2XYZ',
          timeOn: 3000,
          fields: {'NAME': 'Bernd', 'QTH': 'Köln'},
        ),
      );
      await h.qsos.log(
        testQso(
          call: 'G4XYZ',
          timeOn: 2000,
          fields: {'NAME': 'Bob', 'QTH': '100% Town_1'},
        ),
      );
    });

    test('an empty query lists the newest first', () async {
      expect((await dir.search('')).map((i) => i.call), [
        'DL2XYZ',
        'G4XYZ',
        'DL1ABC',
      ]);
    });

    test('matches the start of a call, or a name or place anywhere', () async {
      expect((await dir.search('dl1')).map((i) => i.call), ['DL1ABC']);
      expect((await dir.search('ber')).map((i) => i.call), [
        'DL2XYZ',
        'DL1ABC',
      ]);
      expect((await dir.search('köln')).map((i) => i.call), ['DL2XYZ']);
    });

    test('LIKE wildcards in the query are literal', () async {
      expect((await dir.search('%')).map((i) => i.call), ['G4XYZ']);
      expect((await dir.search('_1')).map((i) => i.call), ['G4XYZ']);
    });

    test('the limit applies', () async {
      expect(await dir.search('', limit: 2), hasLength(2));
    });
  });
}

/// The directory with a small cap, to test the refusal without 500,000 rows.
class _CappedDirectory extends CallsignDirectoryRepository {
  // The super constructor's parameter is private, so it cannot be a super
  // parameter.
  // ignore: use_super_parameters
  new(TidelineDatabase db, {required this.cap}) : super(db);

  final int cap;

  @override
  int get maxRows => cap;
}
