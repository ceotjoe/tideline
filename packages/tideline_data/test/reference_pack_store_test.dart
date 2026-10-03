import 'dart:async';

import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/test_database.dart';

ProgramReference pota(
  String ref,
  String name, {
  String? region,
  double? lat,
  double? lon,
  bool active = true,
}) => ProgramReference(
  program: ReferenceProgram.pota,
  reference: ref,
  name: name,
  region: region,
  latitude: lat,
  longitude: lon,
  active: active,
);

void main() {
  final fetched = DateTime.utc(2026, 10, 3, 12);

  Future<ReferencePackInfo> installPota(
    ReferencePackStore store,
    List<ProgramReference> refs, {
    String sha = 'aa',
  }) => store.install(
    ReferenceProgram.pota,
    Stream.fromIterable(refs),
    sourceUrl: 'https://pota.app/all_parks_ext.csv',
    sha256: sha,
    fetchedAt: fetched,
  );

  final sample = [
    pota(
      'US-0001',
      'Acadia National Park',
      region: 'US-ME',
      lat: 44.3,
      lon: -68.2,
    ),
    pota(
      'US-0002',
      'Acadia Old Trail',
      region: 'US-ME',
      lat: 44.4,
      lon: -68.1,
      active: false,
    ),
    pota('DE-0001', 'Bayerischer Wald', region: 'DE-BY', lat: 48.9, lon: 13.4),
    pota('DE-0002', 'Müritz', region: 'DE-MV', lat: 53.4, lon: 12.7),
    pota('DE-0003', 'Nowhere', region: 'DE-XX'),
    pota('NZ-0001', 'Chatham', region: 'NZ-CH', lat: -44, lon: -176.5),
    pota('FJ-0001', 'Taveuni', region: 'FJ-NO', lat: -16.9, lon: 179.9),
  ];

  test('install stores references; info, find and clear work', () async {
    final store = ReferencePackStore(await openTestDatabase());
    expect(await store.info(ReferenceProgram.pota), isNull);

    final info = await installPota(store, sample);
    expect(info.count, 7);
    expect(info.version, '2026-10-03');
    final stored = (await store.info(ReferenceProgram.pota))!;
    expect(stored.count, 7);
    expect(stored.sha256, 'aa');
    expect(stored.sourceUrl, 'https://pota.app/all_parks_ext.csv');
    expect(stored.fetchedAt, fetched.millisecondsSinceEpoch);

    final acadia = (await store.find(ReferenceProgram.pota, ' us-0001 '))!;
    expect(acadia.name, 'Acadia National Park');
    expect(acadia.latitude, 44.3);
    expect(acadia.active, isTrue);
    expect(
      (await store.find(ReferenceProgram.pota, 'US-0002'))!.active,
      isFalse,
    );
    expect(await store.find(ReferenceProgram.sota, 'US-0001'), isNull);

    await store.clear(ReferenceProgram.pota);
    expect(await store.info(ReferenceProgram.pota), isNull);
    expect(await store.find(ReferenceProgram.pota, 'US-0001'), isNull);
  });

  test('the source date becomes the version; dates round-trip', () async {
    final store = ReferencePackStore(await openTestDatabase());
    await store.install(
      ReferenceProgram.sota,
      Stream.value(
        ProgramReference(
          program: ReferenceProgram.sota,
          reference: 'G/LD-001',
          name: 'Scafell Pike',
          validFrom: DateTime.utc(2023, 5),
          validTo: DateTime.utc(2024, 4, 30),
        ),
      ),
      sourceUrl: 'https://storage.sota.org.uk/summitslist.csv',
      sha256: 'bb',
      fetchedAt: fetched,
      sourceDate: DateTime.utc(2026, 9, 30),
      licenceNote: 'user download',
    );
    final info = (await store.info(ReferenceProgram.sota))!;
    expect(info.version, '2026-09-30');
    expect(info.licenceNote, 'user download');
    final r = (await store.find(ReferenceProgram.sota, 'G/LD-001'))!;
    expect(r.validFrom, DateTime.utc(2023, 5));
    expect(r.validTo, DateTime.utc(2024, 4, 30));
  });

  test('a new install replaces the old rows of that programme only', () async {
    final store = ReferencePackStore(await openTestDatabase());
    await installPota(store, sample);
    await store.install(
      ReferenceProgram.wwff,
      Stream.value(
        const ProgramReference(
          program: ReferenceProgram.wwff,
          reference: 'DLFF-0001',
          name: 'Wald',
        ),
      ),
      sourceUrl: 'https://wwff.co/wwff-data/wwff_directory.csv',
      sha256: 'cc',
      fetchedAt: fetched,
    );
    final info = await installPota(store, [pota('K-0001', 'Only')], sha: 'dd');
    expect(info.count, 1);
    expect(await store.find(ReferenceProgram.pota, 'US-0001'), isNull);
    expect(await store.find(ReferenceProgram.pota, 'K-0001'), isNotNull);
    expect((await store.info(ReferenceProgram.pota))!.sha256, 'dd');
    expect((await store.info(ReferenceProgram.wwff))!.count, 1);
  });

  test('a failing stream leaves the installed pack untouched', () async {
    final store = ReferencePackStore(await openTestDatabase());
    await installPota(store, sample);

    Stream<ProgramReference> broken() async* {
      yield pota('K-0001', 'New');
      throw const ReferencePackFormatException('boom');
    }

    await expectLater(
      store.install(
        ReferenceProgram.pota,
        broken(),
        sourceUrl: 'x',
        sha256: 'ee',
        fetchedAt: fetched,
      ),
      throwsA(isA<ReferencePackFormatException>()),
    );
    expect((await store.info(ReferenceProgram.pota))!.count, 7);
    expect((await store.info(ReferenceProgram.pota))!.sha256, 'aa');
    expect(await store.find(ReferenceProgram.pota, 'K-0001'), isNull);
    expect(await store.find(ReferenceProgram.pota, 'US-0001'), isNotNull);

    // The store is usable again afterwards.
    expect((await installPota(store, [pota('K-0002', 'Two')])).count, 1);
  });

  test('references of another programme are refused', () async {
    final store = ReferencePackStore(await openTestDatabase());
    await installPota(store, sample);
    await expectLater(
      store.install(
        ReferenceProgram.sota,
        Stream.value(pota('US-0009', 'Wrong')),
        sourceUrl: 'x',
        sha256: 'ee',
        fetchedAt: fetched,
      ),
      throwsArgumentError,
    );
    expect(await store.info(ReferenceProgram.sota), isNull);
    expect((await store.info(ReferenceProgram.pota))!.count, 7);
  });

  test('two installs at once: the second is refused', () async {
    final store = ReferencePackStore(await openTestDatabase());
    final gate = StreamController<ProgramReference>();
    final first = installPota(store, const []).then((_) {});
    // `first` finishes quickly; use a stream that stays open instead.
    await first;
    final slow = store.install(
      ReferenceProgram.pota,
      gate.stream,
      sourceUrl: 'x',
      sha256: 'ff',
      fetchedAt: fetched,
    );
    await expectLater(installPota(store, sample), throwsStateError);
    gate.add(pota('K-0001', 'One'));
    await gate.close();
    expect((await slow).count, 1);
  });

  test('duplicate references in a stream: the last one wins', () async {
    final store = ReferencePackStore(await openTestDatabase());
    final info = await installPota(store, [
      pota('K-0001', 'First'),
      pota('K-0001', 'Second'),
    ]);
    expect(info.count, 1);
    expect((await store.find(ReferenceProgram.pota, 'K-0001'))!.name, 'Second');
  });

  group('search', () {
    late ReferencePackStore store;
    setUp(() async {
      store = ReferencePackStore(await openTestDatabase());
      await installPota(store, sample);
    });

    List<String> refs(List<ProgramReference> l) =>
        l.map((r) => r.reference).toList();

    test('by reference, name and region; retired are left out', () async {
      expect(refs(await store.search('acadia')), ['US-0001']);
      expect(refs(await store.search('acadia', includeInactive: true)), [
        'US-0001',
        'US-0002',
      ]);
      expect(refs(await store.search('de-by')), ['DE-0001']);
      expect(refs(await store.search('wald')), ['DE-0001']);
      expect(refs(await store.search('DE-')), [
        'DE-0001',
        'DE-0002',
        'DE-0003',
      ]);
    });

    test('every word must match; exact reference first', () async {
      expect(refs(await store.search('national acadia')), ['US-0001']);
      expect(await store.search('national bayerischer'), isEmpty);
      final list = [
        pota('K-0010', 'Park K-0001 Annex'),
        pota('K-0001', 'Main'),
      ];
      await installPota(store, list);
      expect(refs(await store.search('k-0001')), ['K-0001', 'K-0010']);
    });

    test('wildcards in the query are plain characters', () async {
      expect(await store.search('%'), isEmpty);
      expect(await store.search('_'), isEmpty);
      expect(await store.search(r'\'), isEmpty);
      expect(await store.search("' OR 1=1 --"), isEmpty);
    });

    test('empty query, limit and programme filter', () async {
      expect(await store.search('   '), isEmpty);
      expect(await store.search('DE-', limit: 2), hasLength(2));
      expect(
        await store.search('DE-', program: ReferenceProgram.sota),
        isEmpty,
      );
    });
  });

  group('nearest', () {
    late ReferencePackStore store;
    setUp(() async {
      store = ReferencePackStore(await openTestDatabase());
      await installPota(store, sample);
    });

    test('sorted by distance, without coordinates or retired ones', () async {
      final near = await store.nearest(ReferenceProgram.pota, 50, 12, limit: 3);
      expect(near.map((e) => e.reference.reference), [
        'DE-0001',
        'DE-0002',
        'US-0001',
      ]);
      expect(near[0].km, lessThan(near[1].km));
      final all = await store.nearest(ReferenceProgram.pota, 50, 12, limit: 50);
      expect(all.map((e) => e.reference.reference), isNot(contains('DE-0003')));
      expect(all.map((e) => e.reference.reference), isNot(contains('US-0002')));
    });

    test('finds a park across the antimeridian', () async {
      final near = await store.nearest(
        ReferenceProgram.pota,
        -16.5,
        -179.8,
        limit: 1,
      );
      expect(near.single.reference.reference, 'FJ-0001');
      expect(near.single.km, lessThan(100));
    });

    test('nothing installed gives an empty list', () async {
      expect(await store.nearest(ReferenceProgram.sota, 0, 0), isEmpty);
    });
  });

  test('watchInfo follows install and clear', () async {
    final store = ReferencePackStore(await openTestDatabase());
    final events = <int?>[];
    final sub = store
        .watchInfo(ReferenceProgram.pota)
        .listen((i) => events.add(i?.count));
    Future<void> until(bool Function() done) async {
      for (var i = 0; i < 200 && !done(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    await until(() => events.isNotEmpty);
    expect(events.last, isNull);
    await installPota(store, sample);
    await until(() => events.last == 7);
    expect(events.last, 7);
    await store.clear(ReferenceProgram.pota);
    await until(() => events.last == null);
    expect(events.last, isNull);
    await sub.cancel();
  });

  test('a pack of 100,000 references installs and searches', () async {
    final store = ReferencePackStore(await openTestDatabase());
    final info = await store.install(
      ReferenceProgram.pota,
      Stream.fromIterable([
        for (var i = 0; i < 100000; i++)
          pota(
            'XX-${i.toString().padLeft(6, '0')}',
            'Park $i',
            region: 'R${i % 50}',
            lat: (i % 1700) / 10 - 85,
            lon: (i % 3500) / 10 - 175,
          ),
      ]),
      sourceUrl: 'x',
      sha256: 'big',
      fetchedAt: fetched,
    );
    expect(info.count, 100000);
    final sw = Stopwatch()..start();
    expect(await store.search('park 99999'), hasLength(1));
    final near = await store.nearest(ReferenceProgram.pota, 10, 10, limit: 5);
    expect(near, hasLength(5));
    expect(sw.elapsed, lessThan(const Duration(seconds: 5)));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
