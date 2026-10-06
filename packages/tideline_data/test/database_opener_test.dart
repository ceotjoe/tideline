import 'dart:io';

import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/memory_secret_store.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('tideline_open_');
    file = File('${dir.path}/tideline.sqlite');
  });

  tearDown(() => dir.delete(recursive: true));

  test('data round-trips in a plain SQLite file', () async {
    final db = TidelineDatabase(openDatabaseExecutor(file));
    await db
        .into(db.settings)
        .insert(SettingsCompanion.insert(key: 'callsign', value: 'DO1HOZ'));
    await db.close();

    expect(
      String.fromCharCodes(await file.readAsBytes()),
      startsWith('SQLite format 3'),
    );
    final again = TidelineDatabase(openDatabaseExecutor(file));
    addTearDown(again.close);
    expect((await again.select(again.settings).get()).single.value, 'DO1HOZ');
  });

  test('foreign keys are enforced', () async {
    final db = TidelineDatabase(openDatabaseExecutor(file));
    addTearDown(db.close);
    await expectLater(
      db
          .into(db.stationProfiles)
          .insert(
            StationProfilesCompanion.insert(
              id: 'sp',
              accountId: 'missing-account',
              remoteId: 1,
              name: 'Home',
              callsign: 'DO1HOZ',
              fetchedAt: 0,
            ),
          ),
      throwsA(predicate<Object>((e) => e.toString().contains('FOREIGN KEY'))),
    );
  });

  test('schema creates every table', () async {
    final db = TidelineDatabase(openDatabaseExecutor(file));
    addTearDown(db.close);
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    for (final table in db.allTables) {
      expect(names, contains(table.actualTableName));
    }
  });

  group('moveUnreadableDatabaseAside', () {
    final now = DateTime.utc(2026, 10, 6);

    test('leaves a missing, empty or plain database alone', () async {
      expect(await moveUnreadableDatabaseAside(file, now: now), isNull);
      await file.writeAsBytes([]);
      expect(await moveUnreadableDatabaseAside(file, now: now), isNull);
      final db = TidelineDatabase(openDatabaseExecutor(file));
      await db.customSelect('SELECT 1').get();
      await db.close();
      expect(await moveUnreadableDatabaseAside(file, now: now), isNull);
      expect(file.existsSync(), isTrue);
    });

    test(
      'renames an unreadable (formerly encrypted) file and its journals',
      () async {
        await file.writeAsBytes(
          List.generate(4096, (i) => (i * 31 + 7) & 0xff),
        );
        await File('${file.path}-wal').writeAsBytes([1, 2, 3]);
        final moved = await moveUnreadableDatabaseAside(file, now: now);
        expect(moved, '${file.path}.unreadable-${now.millisecondsSinceEpoch}');
        expect(file.existsSync(), isFalse);
        expect(File(moved!).existsSync(), isTrue);
        expect(File('$moved-wal').existsSync(), isTrue);
        expect(File('${file.path}-wal').existsSync(), isFalse);
      },
    );

    test('a file shorter than the header counts as unreadable', () async {
      await file.writeAsBytes([1, 2, 3]);
      expect(await moveUnreadableDatabaseAside(file, now: now), isNotNull);
    });
  });

  test('DeviceIdProvider is stable', () async {
    final store = MemorySecretStore();
    final id = await DeviceIdProvider(store).obtain();
    expect(isUuid(id), isTrue);
    expect(await DeviceIdProvider(store).obtain(), id);
  });
}
