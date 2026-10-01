import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';

const _key = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
const _otherKey =
    'ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766554433221100';

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('tideline_enc_');
    file = File('${dir.path}/tideline.db');
  });

  tearDown(() => dir.delete(recursive: true));

  Future<void> writeSample(String key) async {
    final db = TidelineDatabase(openEncryptedExecutor(file, hexKey: key));
    await db
        .into(db.settings)
        .insert(SettingsCompanion.insert(key: 'callsign', value: 'DO1HOZ'));
    await db.close();
  }

  test('linked SQLite supports encryption (sqlite3mc build hook)', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    expect(db.select('PRAGMA cipher'), isNotEmpty);
  });

  test('data round-trips with the right key', () async {
    await writeSample(_key);
    final db = TidelineDatabase(openEncryptedExecutor(file, hexKey: _key));
    addTearDown(db.close);
    final rows = await db.select(db.settings).get();
    expect(rows.single.value, 'DO1HOZ');
  });

  test('file on disk contains no plaintext', () async {
    await writeSample(_key);
    final bytes = await file.readAsBytes();
    final latin1 = String.fromCharCodes(bytes);
    expect(latin1.contains('DO1HOZ'), isFalse);
    expect(latin1.startsWith('SQLite format 3'), isFalse);
  });

  test('opening without a key fails', () async {
    await writeSample(_key);
    final plain = sqlite3.open(file.path);
    addTearDown(plain.close);
    expect(
      () => plain.select('SELECT * FROM settings'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('opening with the wrong key fails clearly', () async {
    await writeSample(_key);
    final db = TidelineDatabase(openEncryptedExecutor(file, hexKey: _otherKey));
    addTearDown(db.close);
    await expectLater(
      db.select(db.settings).get(),
      throwsA(
        anyOf(
          isA<DatabaseEncryptionException>(),
          predicate<Object>(
            (e) => e.toString().contains('DatabaseEncryptionException'),
          ),
        ),
      ),
    );
  });

  test('rejects malformed keys without echoing them', () {
    expect(
      () => openEncryptedExecutor(file, hexKey: "x'; DROP TABLE qsos; --"),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.toString(),
          'message',
          isNot(contains('DROP')),
        ),
      ),
    );
  });

  test('key-setting errors never contain the key', () {
    final db = sqlite3.openInMemory(); // cannot be encrypted
    addTearDown(db.close);
    expect(
      () => applyEncryption(db, _key),
      throwsA(
        isA<DatabaseEncryptionException>().having(
          (e) => e.toString(),
          'message',
          isNot(contains(_key)),
        ),
      ),
    );
  });

  test('foreign keys are enforced', () async {
    final db = TidelineDatabase(openEncryptedExecutor(file, hexKey: _key));
    addTearDown(db.close);
    // Sanity check: the database itself opens fine.
    expect(await db.select(db.settings).get(), isEmpty);
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
      // The background isolate wraps the SqliteException.
      throwsA(predicate<Object>((e) => e.toString().contains('FOREIGN KEY'))),
    );
  });

  test('schema creates every table', () async {
    final db = TidelineDatabase(openEncryptedExecutor(file, hexKey: _key));
    addTearDown(db.close);
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    for (final table in db.allTables) {
      expect(names, contains(table.actualTableName));
    }
  });
}
