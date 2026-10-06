import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/test_database.dart';

void main() {
  final fetched = DateTime.utc(2026, 10, 1, 12);

  test('replace stores calls and pack row; load/info/clear work', () async {
    final store = ScpStore(await openTestDatabase());
    expect(await store.load(), isNull);
    expect(await store.info(), isNull);

    final info = await store.replace(
      '# comment\nDL1ABC\ndo1hoz\nDL1ABC\n\nX\n',
      sourceUrl: 'https://example.org/MASTER.SCP',
      fetchedAt: fetched,
    );
    expect(info.callCount, 2);
    expect(info.sha256, hasLength(64));
    final scp = (await store.load())!;
    expect(scp.length, 2);
    expect(scp.contains('DO1HOZ'), isTrue);
    final stored = (await store.info())!;
    expect(stored.sha256, info.sha256);
    expect(stored.sourceUrl, 'https://example.org/MASTER.SCP');
    expect(stored.fetchedAt, fetched.millisecondsSinceEpoch);

    await store.replace(
      'DL9ZZZ\n',
      sourceUrl: 'https://example.org/other',
      fetchedAt: fetched,
    );
    expect((await store.load())!.calls, ['DL9ZZZ']);
    expect((await store.info())!.sha256, isNot(info.sha256));

    await store.clear();
    expect(await store.load(), isNull);
    expect(await store.info(), isNull);
  });

  test('a failing replace leaves the stored data untouched', () async {
    final store = ScpStore(await openTestDatabase());
    await store.replace('DL1ABC\n', sourceUrl: 'u', fetchedAt: fetched);
    await expectLater(
      store.replace(
        'A' * (9 * 1024 * 1024),
        sourceUrl: 'u',
        fetchedAt: fetched,
      ),
      throwsA(isA<ScpFormatException>()),
    );
    expect((await store.load())!.calls, ['DL1ABC']);
  });

  test('replaces 50,000 calls quickly', () async {
    final store = ScpStore(await openTestDatabase());
    final text = [
      for (var i = 0; i < 50000; i++) 'DL${i.toString().padLeft(5, '0')}A',
    ].join('\n');
    final watch = Stopwatch()..start();
    final info = await store.replace(text, sourceUrl: 'u', fetchedAt: fetched);
    watch.stop();
    expect(info.callCount, 50000);
    // A budget that still catches a per-row regression but tolerates a slow
    // CI runner (Windows took 3 s).
    expect(watch.elapsed, lessThan(const Duration(seconds: 6)));
    expect((await store.load())!.length, 50000);
  });
}
